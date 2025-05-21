extends CharacterState
## A state that moves the character toward a target using NavigationAgent3D
class_name PathfindState

@export var target_node: Node3D  # The node to move toward
@export var speed: float = 5.0   # Movement speed
@export var animation_name : String = "anim_library/walking"

var navigation_agent: NavigationAgent3D
var character_body: CharacterBody3D

func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)

	character_body = state_machine_controller.get_parent() as CharacterBody3D
	if character_body == null:
		push_error("StateMachineController must be a child of a CharacterBody3D.")
		return

	navigation_agent = character_body.get_node_or_null("NavigationAgent3D")
	if navigation_agent == null:
		push_error("NavigationAgent3D not found as child of CharacterBody3D.")
		return

	if target_node != null:
		navigation_agent.target_position = target_node.global_position
	else:
		push_warning("No target_node set for PathfindState.")

func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)

func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	if navigation_agent == null or character_body == null:
		return

	if navigation_agent.is_navigation_finished():
		state_machine_controller.set_state(fallback_state)
		return
	
	var animator: AnimationPlayer = state_machine_controller.get_parent().playermodel.get_child(0).get_node_or_null("AnimationPlayer")
	if animator != null:
		if not animator.is_playing() or animator.current_animation != animation_name:
			animator.play(animation_name)
	
	var next_position: Vector3 = navigation_agent.get_next_path_position()
	var direction: Vector3 = (next_position - character_body.global_position)
	direction.y = 0  # Remove vertical component
	direction = direction.normalized()
	var velocity: Vector3 = direction * speed
	
	
	character_body.velocity = velocity
	character_body.move_and_slide()
	
	# Optional: face movement direction
	if velocity.length() > 0.1:
		character_body.look_at(character_body.global_position - direction, Vector3.UP)
