extends CharacterState
## Stand still and animate
class_name IdleState

@export var do_random_state: bool = false
## The chance of the random state is 1 in random_chance every physics frame
@export var random_chance: int = 200
## Swaps to this state randomly
@export var random_state: CharacterState

# Called when this state is entered
func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	# Additional logic for entering idle can go here

# Called when this state is exited
func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)
	# Additional logic for exiting idle can go here

# Called every physics frame
func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	state_machine_controller.get_parent().velocity = Vector3.ZERO

	var animator: AnimationPlayer = state_machine_controller.get_parent().playermodel.get_child(0).get_node_or_null("AnimationPlayer")
	if animator != null:
		if not animator.is_playing() or animator.current_animation != "anim_library/idle":
			animator.play("anim_library/idle")
	
	if do_random_state and random_state != null:
		var chance: int = randi_range(1, random_chance)
		if chance == 1:
			state_machine_controller.set_state(random_state)

# Called every regular frame (optional)
func update_state(delta: float, state_machine_controller: StateMachineController) -> void:
	super.update_state(delta, state_machine_controller)
