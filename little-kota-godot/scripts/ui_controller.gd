extends Control

@export var ollama_controller : OllamaAPI

func _on_send_message_pressed() -> void:
	ollama_controller.send_chat_request($MessageEdit.text)
	$SendMessage.text = "Thinking..."
	$SendMessage.disabled = true
	await(ollama_controller.receieved_response)
	$SendMessage.text = "Send Message"
	$SendMessage.disabled = false
	$RichTextLabel.text = ollama_controller.response_message
