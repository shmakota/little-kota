@tool
extends Node
class_name OllamaController

@export var prompt_text = "why is the sky blue? one sentence"
@export var print_on_ready = true

func _ready():
	if !find_child("OllamaAPI"):
		var ollama_api = OllamaAPI.new()
		ollama_api.name = "OllamaAPI"
		add_child(ollama_api)
	
	if print_on_ready:
		find_child("OllamaAPI").send_chat_request(prompt_text)
