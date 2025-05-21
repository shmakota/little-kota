extends Node
class_name OllamaAPI

signal received_api_response

# Configuration
@export var ollama_model_name: String = ""
@export var system_prompt: String = ""
@export var update_history: bool = false
@export var busy : bool = false
@export var constant_reminder : bool = false
@export var prompt_engineering_prompt: String = ""
@export var prompt_engineering_failure: String = ""

@export_category("Results")
@export var last_response: String = ""

@onready var chat_history: Array = [
	{
		"role": "system",
		"content": system_prompt
	}
]

func reset_chat_history():
	chat_history = [
		{
			"role": "system",
			"content": system_prompt
		}
	]

@onready var http_request: HTTPRequest
@onready var validation_request: HTTPRequest

func _ready():
	BaseGlobals.ollama_api_node = self
	http_request = HTTPRequest.new()
	validation_request = HTTPRequest.new()
	add_child(http_request)
	add_child(validation_request)

enum ModelTemplates {NONE, NEMOTRON}
var model_temp : ModelTemplates = ModelTemplates.NONE

var _pending_request_username := ""
var _pending_request_text := ""

func send_chat_request(username : String, chat_request_text: String) -> void:
	if busy:
		printerr("OllamaAPI is already busy with a different request.")
		return
	
	_pending_request_username = username
	_pending_request_text = chat_request_text
	
	if prompt_engineering_prompt.strip_edges() != "":
		_validate_prompt_with_llm(chat_request_text)
	else:
		_execute_chat_request("user", chat_request_text)

func _validate_prompt_with_llm(user_input: String) -> void:
	print("Running LLM-based prompt validation...")
	busy = true
	
	var validation_string = "Policy: \"%s\"\nMessage: \"%s\"\nIs this message valid under this policy? Respond only with true or false."% [prompt_engineering_prompt, user_input]
	var validation_chat := [
		{"role": "system", "content": "You are a moderation filter. Answer only with 'true' or 'false'."},
		{"role": "user", "content": validation_string }
	]

	var url := "http://127.0.0.1:11434/api/chat"
	var headers: PackedStringArray = ["Content-Type: application/json"]
	var data := {
		"model": ollama_model_name,
		"messages": validation_chat,
		"stream": false
	}
	var json_string: String = JSON.stringify(data)

	validation_request.request_completed.connect(_on_validation_completed)
	var err := validation_request.request(url, headers, HTTPClient.METHOD_POST, json_string)

	if err != OK:
		push_error("Validation HTTP request failed: %s" % err)
		busy = false

func _on_validation_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	validation_request.request_completed.disconnect(_on_validation_completed)
	print("validation complete")

	var response_text: String = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)

	if json and json.has("message") and json["message"].has("content"):
		var raw_response = json["message"]["content"].strip_edges().to_lower()
		print("Validation LLM response: %s" % raw_response)
		if raw_response == "true":
			_execute_chat_request("user", _pending_request_text)
		else:
			print("Prompt validation failed. Message blocked.")
			add_user_message(_pending_request_text)
			_execute_chat_request("system", "FAILURE! " + prompt_engineering_failure) 
			busy = false
	else:
		print("Validation failed due to malformed response.")
		busy = false

func add_system_message(content: String) -> void:
	chat_history.append({
		"role": "system",
		"content": content
	})

func add_user_message(content: String) -> void:
	chat_history.append({
		"role": "user",
		"content": content
	})

func _execute_chat_request(role: String, chat_request_text: String) -> void:
	print("Starting _execute_chat_request()...")

	var combined_content = ""
	match model_temp:
		ModelTemplates.NONE:
			combined_content += chat_request_text
		ModelTemplates.NEMOTRON:
			if role == "user":
				combined_content += "<extra_id_1>User\n{" + chat_request_text + "}"
			elif role == "system":
				combined_content += "<extra_id_1>System\n{" + chat_request_text + "}"
			else:
				combined_content += chat_request_text  # fallback

	match role:
		"user":
			add_user_message(combined_content)
		"system":
			add_system_message(combined_content)
		_:
			push_error("Unknown role: %s" % role)
			return

	if constant_reminder and role != "system":
		# optionally keep adding system prompt on user messages only
		add_system_message(system_prompt)

	var url: String = "http://127.0.0.1:11434/api/chat"
	var headers: PackedStringArray = ["Content-Type: application/json"]

	print("Sent chat history: " + str(chat_history))
	var data := {
		"model": ollama_model_name,
		"messages": chat_history,
		"stream": false
	}
	var json_string := JSON.stringify(data)

	http_request.request_completed.connect(_on_request_completed)
	var err := http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)

	if err != OK:
		push_error("Failed to send HTTP request: %s" % err)
	else:
		print("HTTP POST request sent successfully.")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	http_request.request_completed.disconnect(_on_request_completed)
	print("Request completed with response code: %d" % response_code)

	var response_text: String = body.get_string_from_utf8()
	var json_result := JSON.new()
	var parse_result := json_result.parse(response_text)

	if parse_result != OK:
		print("Failed to parse JSON response. Raw response: %s" % response_text)
		busy = false
		return

	var json: Variant = json_result.get_data()

	if typeof(json) == TYPE_DICTIONARY and json.has("message") and json["message"].has("content"):
		last_response = json["message"]["content"]
		print("Assistant response: %s" % last_response)
		
		if update_history:
			chat_history.append({
				"role": "assistant",
				"content": last_response
			})
		
		emit_signal("received_api_response")
	else:
		print("Invalid response structure: %s" % response_text)
	
	busy = false
