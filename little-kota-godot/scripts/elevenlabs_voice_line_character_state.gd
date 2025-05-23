extends CharacterState
class_name ElevenlabsVoiceLineState

@export var elevenlabs_api_node_path: NodePath
@export var character_node: Node
@export var voice_line_text: String
@export var voice_id: String
@export var animation_name: String = ""
@export var wait_for_audio_finish: bool = true
@export var audio_timeout_seconds: float = 5.0  # Timeout duration
@export var animation_only_mode: bool = false   # NEW: Toggle for animation only

var _animator: AnimationPlayer = null
var _finished_callable: Callable = Callable()
var _elevenlabs_api: ElevenlabsAPI = null
var _audio_player: AudioStreamPlayer3D = null

var smc_copy : StateMachineController
var _timeout_timer: Timer = null
var _audio_started: bool = false

func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	smc_copy = state_machine_controller
	state_machine_controller.get_parent().velocity = Vector3.ZERO
	_audio_started = false

	# Start animation
	_animator = state_machine_controller.get_parent().playermodel.get_child(0).get_node_or_null("AnimationPlayer")
	if animation_name != "" and _animator != null:
		_animator.play(animation_name)

	# Skip voice line logic if in animation-only mode
	if animation_only_mode:
		print("Animation-only mode: skipping ElevenLabs voice line.")
		await(get_tree().create_timer(3).timeout)
		if fallback_state != null and smc_copy != null:
			smc_copy.set_state(fallback_state)
		return

	# Get ElevenLabs API node
	_elevenlabs_api = get_node_or_null(elevenlabs_api_node_path)
	if _elevenlabs_api == null:
		push_error("ElevenLabs API node not found at path: %s" % elevenlabs_api_node_path)
		_fallback_due_to_timeout()
		return

	_audio_player = _elevenlabs_api.get_node_or_null("AudioStreamPlayer3D")
	if _audio_player == null:
		push_error("AudioStreamPlayer3D not found in ElevenLabsAPI node.")
		_fallback_due_to_timeout()
		return

	# Connect to audio finished signal
	if wait_for_audio_finish and fallback_state != null:
		_finished_callable = Callable(self, "_on_audio_finished")
		if not _audio_player.is_connected("finished", _finished_callable):
			_audio_player.connect("finished", _finished_callable)

	# Start a timer for timeout
	_timeout_timer = Timer.new()
	_timeout_timer.wait_time = audio_timeout_seconds
	_timeout_timer.one_shot = true
	_timeout_timer.connect("timeout", Callable(self, "_on_audio_timeout"))
	add_child(_timeout_timer)
	_timeout_timer.start()

	# Request voice line
	_elevenlabs_api.send_text_request(voice_line_text)

func _process(delta):
	if animation_only_mode:
		return

	if _audio_player != null and not _audio_started:
		if _audio_player.playing:
			_audio_started = true
			if _timeout_timer != null and _timeout_timer.is_stopped() == false:
				_timeout_timer.stop()

func _on_audio_timeout() -> void:
	print("Audio timeout triggered: no audio started within %f seconds" % audio_timeout_seconds)
	
	if animation_name != "" and _animator != null and not _animator.is_playing():
		_animator.play(animation_name)

	_fallback_due_to_timeout()

func _fallback_due_to_timeout():
	if fallback_state != null and smc_copy != null:
		smc_copy.set_state(fallback_state)
	else:
		print("Fallback state or state machine controller is null on timeout.")

func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)

	if _audio_player != null and _finished_callable.is_valid():
		if _audio_player.is_connected("finished", _finished_callable):
			_audio_player.disconnect("finished", _finished_callable)

	if _timeout_timer != null:
		_timeout_timer.queue_free()
		_timeout_timer = null

	_animator = null
	_audio_player = null
	_finished_callable = Callable()
	_audio_started = false

func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	state_machine_controller.get_parent().velocity = Vector3.ZERO

func update_state(delta: float, state_machine_controller: StateMachineController) -> void:
	super.update_state(delta, state_machine_controller)

	if not wait_for_audio_finish and fallback_state != null:
		if smc_copy != null:
			smc_copy.set_state(fallback_state)

func _on_audio_finished() -> void:
	print("audio finished")
	if fallback_state != null:
		if smc_copy != null:
			smc_copy.set_state(fallback_state)
			print("audio finished")
		else:
			print("controller is null")
