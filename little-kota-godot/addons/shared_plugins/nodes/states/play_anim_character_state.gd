extends CharacterState
## Plays a specified animation while standing still
class_name PlayAnimationState

@export var animation_name: String = "anim_library/idle"

var _animator: AnimationPlayer = null
var _finished_callable: Callable = Callable()

func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	state_machine_controller.get_parent().velocity = Vector3.ZERO

	_animator = state_machine_controller.get_parent().playermodel.get_child(0).get_node_or_null("AnimationPlayer")

	if _animator != null:
		if not _animator.is_playing() or _animator.current_animation != animation_name:
			_animator.play(animation_name)

		# Connect to animation_finished if fallback_state is set
		if fallback_state != null:
			_finished_callable = Callable(self, "_on_animation_finished")
			if not _animator.is_connected("animation_finished", _finished_callable):
				_animator.connect("animation_finished", _finished_callable)

func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)

	if _animator != null and _finished_callable.is_valid():
		if _animator.is_connected("animation_finished", _finished_callable):
			_animator.disconnect("animation_finished", _finished_callable)

	_animator = null
	_finished_callable = Callable()

func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	state_machine_controller.get_parent().velocity = Vector3.ZERO

	if _animator != null and (not _animator.is_playing() or _animator.current_animation != animation_name):
		_animator.play(animation_name)

func update_state(delta: float, state_machine_controller: StateMachineController) -> void:
	super.update_state(delta, state_machine_controller)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == animation_name and fallback_state != null:
		var controller := owner as StateMachineController
		if controller != null:
			controller.set_state(fallback_state)
