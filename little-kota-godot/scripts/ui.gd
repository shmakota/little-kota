extends Control

@export var ollama_api : OllamaAPI
@export var camera : Node3D
@export var use_closest_chatting_character: bool = false

func _physics_process(delta: float) -> void:
	ollama_api.ollama_model_name = $ModelNameEdit.text
	$SendMessage.text = "Thinking..." if ollama_api.busy else "Send Message"
	$SendMessage.disabled = true if ollama_api.busy else false
	$HistorySize.text = str(ollama_api.chat_history.size())
	if "\n" in $MessageEdit.text:
		$ResponseLabel.text = $MessageEdit.text
		do_think()
		$MessageEdit.text = ""

func do_think():
	if use_closest_chatting_character:
		var character = get_closest_chatting_character()
		if character:
			var char_smc = character.find_child("StateMachineController")
			var input_state = char_smc.find_child("PlayerInputState")
			input_state.player_input_text =  $MessageEdit.text
			char_smc.set_state(input_state)
			await ollama_api.received_api_response  # Assuming ChattingCharacter has a signal or awaitable property
			$ResponseLabel.text = ollama_api.last_response
		else:
			$ResponseLabel.text = "No ChattingCharacter found!"
	else:
		ollama_api.send_chat_request($UserEdit.text, $MessageEdit.text)
		await(ollama_api.received_api_response)
		$ResponseLabel.text = ollama_api.last_response

func get_closest_chatting_character() -> ChattingCharacter:
	var closest_character: ChattingCharacter = null
	var closest_dist = INF
	var origin = camera.global_transform.origin

	for character in get_tree().get_nodes_in_group("characters"):
		if character is ChattingCharacter:
			var dist = origin.distance_to(character.global_transform.origin)
			if dist < closest_dist:
				closest_dist = dist
				closest_character = character

	return closest_character

func _on_send_message_pressed() -> void:
	$ResponseLabel.text = $MessageEdit.text
	do_think()
	$MessageEdit.text = ""

func _on_clear_history_pressed() -> void:
	$ResponseLabel.text = ""
	ollama_api.system_prompt = $SystemPromptEdit.text
	ollama_api.reset_chat_history()
