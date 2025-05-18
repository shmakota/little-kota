extends AudioStreamPlayer3D

# Audio recording
var effect: AudioEffectRecord
var recording: AudioStream

# State flags
@export var record_voice: bool = false
var save_recording: bool = false

# External dependencies
@export var chat_api: Node
@export var recording_icon : TextureRect

func _ready() -> void:
	# Get the recording effect from the "Record" audio bus
	var record_bus_idx: int = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(record_bus_idx, 0)
	recording = effect.get_recording()

	# Get the ChatAPI node if not assigned
	if chat_api == null:
		chat_api = get_parent().find_child("ChatAPI")

func _physics_process(delta: float) -> void:
	# Toggle recording with input
	if Input.is_action_just_pressed("ui_end"):
		toggle_recording()

func save_recording_to_file() -> void:
	print("Saving recording...")
	recording.save_to_wav(BaseGlobals.wav_file_path)

	var speech_to_text: Node = get_parent().find_child("SpeechToText")
	speech_to_text.recognize_file()

	# Wait briefly to allow speech-to-text processing
	await get_tree().create_timer(3.0).timeout

	# Send the transcribed text to the chat API
	if speech_to_text.last_response != "":
		if is_instance_valid(chat_api):
			chat_api.send_chat_request(speech_to_text.last_response)
	else:
		printerr("CANT FIND PYTHON SPEECH RECOGNITION SERVER")

func toggle_recording() -> void:
	# Get updated recording sample
	recording = effect.get_recording()

	if effect.is_recording_active():
		recording_icon.texture = load("res://textures/mic_off.svg")
		# Stop recording
		record_voice = false
		print("Stopping recording...")
		effect.set_recording_active(false)

		if recording:
			save_recording_to_file()
	else:
		# Start recording
		print("Started recording...")
		recording_icon.texture = load("res://textures/mic_on.svg")
		record_voice = true
		effect.set_recording_active(true)
