extends Control

@export var ollama_api : OllamaAPI

func _on_send_message_pressed() -> void:
	ollama_api.send_chat_request($UserEdit.text, $MessageEdit.text)
	$SendMessage.text = "Thinking..."
	$SendMessage.disabled = true
	await(ollama_api.received_api_response)
	$SendMessage.text = "Send Message"
	$SendMessage.disabled = false
	$ResponseLabel.text = ollama_api.last_response
