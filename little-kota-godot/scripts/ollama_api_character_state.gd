extends CharacterState
## Sends player input + character context to OllamaAPI, and optionally forwards to ElevenLabs voice line state
class_name OllamaThoughtProcessorState

@export var character_node: ChattingCharacter
@export var player_input_text: String
@export var forward_to_voice_line: bool = false
@export var voice_line_state: ElevenlabsVoiceLineState

var _ollama_api: OllamaAPI = null
var smc_copy: StateMachineController
var _response_finished_callable: Callable = Callable()

func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	smc_copy = state_machine_controller
	state_machine_controller.get_parent().velocity = Vector3.ZERO

	# Get OllamaAPI
	_ollama_api = $OllamaAPI#BaseGlobals.ollama_api_node
	if _ollama_api == null:
		push_error("OllamaAPI is not set in BaseGlobals.")
		return
	
	await(get_tree().create_timer(2).timeout)

	# Connect response signal
	_response_finished_callable = Callable(self, "_on_ollama_response")
	if not _ollama_api.is_connected("received_api_response", _response_finished_callable):
		_ollama_api.connect("received_api_response", _response_finished_callable)

	# Compose prompt
	_ollama_api.ollama_model_name = "mannix/llama3.1-8b-abliterated:latest"
	_ollama_api.system_prompt = character_node.character_data.character_prompt
	_ollama_api.send_chat_request("", player_input_text)

func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)

	if _ollama_api and _response_finished_callable.is_valid():
		if _ollama_api.is_connected("received_api_response", _response_finished_callable):
			_ollama_api.disconnect("received_api_response", _response_finished_callable)

	_ollama_api = null
	_response_finished_callable = Callable()

func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	state_machine_controller.get_parent().velocity = Vector3.ZERO

func _on_ollama_response() -> void:
	print("Ollama response: %s" % _ollama_api.last_response)
	
	smc_copy.get_parent().find_child("MessageLabel").text = _ollama_api.last_response
	if forward_to_voice_line and voice_line_state:
		var state = voice_line_state
		if state and "voice_line_text" in state:
			state.voice_line_text = _ollama_api.last_response
			smc_copy.set_state(voice_line_state)
			return

	# Default fallback path
	if fallback_state and smc_copy:
		smc_copy.set_state(fallback_state)
