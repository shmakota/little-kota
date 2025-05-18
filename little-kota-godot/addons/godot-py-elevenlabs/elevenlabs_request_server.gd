extends Node

func send_text_request(text: String) -> void:
	var url := "http://" + BaseGlobals.server_ip_address + ":6003/"
	var json_data := {"text": text}
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)
	
	var err := request.request(
		url,
		["Content-Type: application/json", "Accept: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(json_data)
	)
	
	if err != OK:
		print("Failed to send request:", err)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print(result)
	print(response_code)
	print(headers)
	print(body)
	if response_code == 200:
		var json_text = body.get_string_from_utf8()
		print("Received JSON text:", json_text)

		# Godot 4 style JSON parsing
		var response = JSON.parse_string(json_text)
		
		# Check if parsing returned a dictionary
		if typeof(response) == TYPE_DICTIONARY:
			if response.has("filename"):
				print("Audio generated and saved as:", response["filename"])
				$AudioStreamPlayer3D.stream = load("res://addons/godot-py-elevenlabs/" + response["filename"])
				$AudioStreamPlayer3D.play()
				print("attempting play")
			else:
				print("JSON response missing 'filename' key")
		else:
			print("Failed to parse JSON or not a dictionary")
	else:
		print("Request failed with code:", response_code)
