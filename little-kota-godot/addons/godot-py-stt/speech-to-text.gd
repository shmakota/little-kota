extends Node3D
class_name SpeechToText

signal recieved

var socket = PacketPeerUDP.new()
var server = UDPServer.new()
var lastResponse = ""
@export var filePath = "user://player_dialogue.wav"

func _ready():
	var path = "user://speechtotext.path"
	if !FileAccess.file_exists(path):
		var newFile = FileAccess.open(path, FileAccess.WRITE)
		newFile.store_string("user://speech-to-text.py")
	
	# execute python script with godot
	var output
	
	var file = FileAccess.open("user://speechtotext.path", FileAccess.READ)
	var line = file.get_as_text()
	
	print(line)
	
	OS.execute("python", [line], [""], false, false)
	
	await(get_tree().create_timer(3).timeout)
	
	socket.set_dest_address("127.0.0.1", 6000)
	server.listen(6001)
	
	#recognize_file()

func recognize_file():
	socket.put_packet(filePath.to_ascii_buffer())

func _physics_process(delta):
	# check for response
	server.poll()
	if !server.is_listening():
		print_verbose("waiting for server...")
	
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		#print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		#print("Received data: %s" % [packet.get_string_from_utf8())
		print(packet.get_string_from_utf8())
		lastResponse = packet.get_string_from_utf8()
		
		%Captions.update_caption("[center]["+lastResponse + "]", 3)
