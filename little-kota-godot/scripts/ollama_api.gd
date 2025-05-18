extends Node
class_name OllamaAPI

signal received_api_response

# Configuration
@export var ollama_model_name: String = ""
@export var system_prompt: String = ""
@export var update_history: bool = false

@export_category("Results")
@export var last_response: String = ""
# Persistent conversation history
@onready var chat_history: Array = [
	{
		"role": "system",
		"content": system_prompt
	}
]

func send_chat_request(chat_request_text: String) -> void:
	print("Starting send_chat_request()...")

	# Rebuild chat history if history updates are disabled
	if not update_history:
		chat_history = [
			{
				"role": "system",
				"content": system_prompt
			},
			{
				"role": "user",
				"content": chat_request_text
			}
		]
	else:
		chat_history.append({
			"role": "user",
			"content": chat_request_text
		})

	# Create and configure HTTPRequest node
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)

	var url: String = "http://127.0.0.1:11434/api/chat"
	var headers: PackedStringArray = ["Content-Type: application/json"]

	# Build payload
	print("sent chat history: " + str(chat_history))
	var data := {
		"model": ollama_model_name,
		"messages": chat_history,
		"stream": false
	}
	var json_string: String = JSON.stringify(data)

	# Connect signal and send POST request
	http_request.request_completed.connect(_on_request_completed)
	var err: int = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)

	if err != OK:
		push_error("Failed to send HTTP request: %s" % err)
	else:
		print("HTTP POST request sent successfully.")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Request completed with response code: %d" % response_code)

	var response_text: String = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)

	if json == null:
		print("Failed to parse JSON response.")
		return

	# Validate response format
	if json.has("message") and json["message"].has("content"):
		last_response = json["message"]["content"]
		print("Assistant response: %s" % last_response)
		
		# Optionally append to chat history
		if update_history:
			chat_history.append({
				"role": "assistant",
				"content": last_response
			})
		
		emit_signal("received_api_response")
	else:
		print("Invalid response structure: %s" % response_text)
