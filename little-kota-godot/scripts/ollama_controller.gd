@tool
extends Node
class_name OllamaController

@export var prompt_text = "why is the sky blue? one sentence"

@export var send_on_ready = true

func _ready():
	if !find_child("OllamaAPI"):
		var ollama_api = OllamaAPI.new()
		ollama_api.name = "OllamaAPI"
		add_child(ollama_api)
	if send_on_ready:
		send_message_to_api(prompt_text)


func send_message_to_api(api_prompt):
	find_child("OllamaAPI").send_chat_request(api_prompt)
