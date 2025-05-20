extends Node
class_name ElevenlabsAPI

@export var ollama_api : OllamaAPI
@export var autoforward : bool

func _ready() -> void:
	if autoforward:
		ollama_api.received_api_response.connect(forward_api_response)

func forward_api_response():
	send_text_request(ollama_api.last_response)

func send_text_request(text: String) -> void:
	var url := "http://" + BaseGlobals.server_ip_address + ":6003/"
	var json_data := {
		"text": text,
		"voice_id": BaseGlobals.elevenlabs_voice_id,
		"api_key": BaseGlobals.elevenlabs_api_key  # ✅ Include API key here
	}
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
	print("Result:", result)
	print("Response Code:", response_code)

	if response_code == 200:
		print("Received raw audio data. Size:", body.size())

		var audio_path := "user://temp_audio.ogg"
		var file := FileAccess.open(audio_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()

		var stream := AudioStreamOggVorbis.load_from_file(audio_path)
		if stream:
			$AudioStreamPlayer3D.stream = stream
			$AudioStreamPlayer3D.play()
			print("Playing audio.")
		else:
			print("Failed to load audio stream.")
	else:
		print("Request failed with code:", response_code)
		print("Body:", body.get_string_from_utf8())
