extends Node
class_name OllamaAPI

signal receieved_response

@export var system_prompt = "Respond one sentence at a time. You are patrick star. respond like '[Patrick Star]: Message.' The chat history is: "
@export var last_response = ""
@export var chat_history = [
	{
		"role": "system",
		"content": system_prompt
	}
]
@export var update_history = false


func send_chat_request(chat_request_text):
	print("Starting send_chat_request()...")
	
	if update_history:
		chat_history.append(
			{
			"role": "user",
			"message": chat_request_text
		})

	var http_request = HTTPRequest.new()
	add_child(http_request)
	print("HTTPRequest node created and added to scene tree.")

	var url = "http://127.0.0.1:11434/api/chat"
	print("Request URL set to: %s" % url)

	var headers = ["Content-Type: application/json"]
	print("Request headers: %s" % headers)
	
	print(chat_history)
	
	# Build the JSON data dictionary
	var data = {
		"model": "dolphin-mistral:7b",
		"messages": chat_history,
		"stream": false
	}
	print("Request data (dictionary): %s" % str(data))

	# Convert dictionary to JSON string
	var json_string = JSON.stringify(data)
	print("Serialized JSON string: %s" % json_string)

	# Connect the request completed signal
	http_request.request_completed.connect(_on_request_completed)
	print("Connected request_completed signal to _on_request_completed.")

	# Send POST request
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	if err != OK:
		push_error("Failed to send HTTP request: %s" % err)
		print("Error sending HTTP request: %s" % err)
	else:
		print("HTTP POST request sent successfully.")

	print("send_chat_request() completed.")

func _on_request_completed(result, response_code, headers, body):
	print("Request completed.")
	print("Response code: %s" % response_code)

	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)

	if json == null:
		print("Failed to parse response JSON.")
		return

	if json.has("message") and json["message"].has("content"):
		var content = json["message"]["content"]
		print("Assistant response: %s" % content)
		last_response = content
		if update_history:
			chat_history.append(
				{
				"role": "patrick star",
				"message": last_response
			})
		emit_signal("receieved_response")
	else:
		print("Response JSON did not contain expected fields.")
