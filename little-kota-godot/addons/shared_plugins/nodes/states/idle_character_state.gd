extends CharacterState
## Stand still and animate
class_name IdleState

# Called when this state is entered
func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)

# Called when this state is exited
func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)

# Called every physics frame
func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	state_machine_controller.get_parent().velocity = Vector3.ZERO

	var animator: AnimationPlayer = state_machine_controller.get_parent().playermodel.get_child(0).get_node_or_null("AnimationPlayer")
	if animator != null:
		if not animator.is_playing() or animator.current_animation != "anim_library/idle":
			animator.play("anim_library/idle")
