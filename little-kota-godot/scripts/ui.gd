extends Control

@export var ollama_api : OllamaAPI

func _physics_process(delta: float) -> void:
	ollama_api.ollama_model_name = $ModelNameEdit.text
	$SendMessage.text = "Thinking..." if ollama_api.busy else "Send Message"
	$SendMessage.disabled = true if ollama_api.busy else false
	$HistorySize.text = str(ollama_api.chat_history.size())
	#if "\n" in $MessageEdit.text:
	#	$ResponseLabel.text = $MessageEdit.text
	#	do_think()
	#	$MessageEdit.text = ""

func do_think():
	ollama_api.send_chat_request($UserEdit.text, $MessageEdit.text)
	await(ollama_api.received_api_response)
	$ResponseLabel.text = ollama_api.last_response

func _on_send_message_pressed() -> void:
	$ResponseLabel.text = $MessageEdit.text
	do_think()
	$MessageEdit.text = ""


func _on_clear_history_pressed() -> void:
	$ResponseLabel.text = ""
	ollama_api.system_prompt = $SystemPromptEdit.text
	ollama_api.reset_chat_history()
