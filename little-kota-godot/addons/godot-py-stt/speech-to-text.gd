extends Node3D
class_name SpeechToText

signal received

# Dependencies
@export var file_path: String = "user://player_dialogue.wav"
@export var update_label: RichTextLabel
@export var ui: Control
@export var llm_api: OllamaAPI

# Networking
var socket: PacketPeerUDP = PacketPeerUDP.new()
var server: UDPServer = UDPServer.new()

# Internal state
var last_response: String = ""

func _ready() -> void:
	# Ensure a path file exists
	var path: String = "user://speechtotext.path"
	if not FileAccess.file_exists(path):
		var new_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		new_file.store_string("user://speech-to-text.py")

	# Read the script path from file
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var python_script_path: String = file.get_as_text().strip_edges()
	print(python_script_path)

	# Placeholder for executing external Python script
	# OS.execute("python", [python_script_path], [], false, false)

	# Wait for external service to boot
	await get_tree().create_timer(3.0).timeout

	# Setup UDP communication
	socket.set_dest_address(BaseGlobals.server_ip_address, 6000)
	server.listen(6001)

func recognize_file() -> void:
	# Send the file path to the Python service
	socket.put_packet(BaseGlobals.wav_file_path.to_ascii_buffer())

func _physics_process(delta: float) -> void:
	# Check for incoming UDP packets
	server.poll()

	if not server.is_listening():
		print_verbose("Waiting for server...")

	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet: PackedByteArray = peer.get_packet()
		var received_text: String = packet.get_string_from_utf8()
		print(received_text)

		last_response = received_text
		ask_llm_and_display(received_text)

func ask_llm_and_display(text: String) -> void:
	# Send recognized text to LLM and wait for response
	print("Sending to LLM: ", text)
	update_label.text = text
	llm_api.send_chat_request(ui.get_node("UserEdit").text, text)
	await(llm_api.received_api_response)
	update_label.text = llm_api.last_response
