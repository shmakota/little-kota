extends CharacterState
## Chooses a random point within range and delegates movement to a pathfinding state.
class_name WanderState

var random_position: Vector3 = Vector3.ZERO
var reached_target_distance: float = 1.0

@export var wander_range: Vector2 = Vector2(0.0, 10.0)  # (min, max) range for distance
@export var pathfind_state: PathfindState

# Called when entering the wander state
func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	print("Entering WanderState")

	var character: CharacterBody3D = state_machine_controller.get_parent() as CharacterBody3D
	if character == null:
		push_error("StateMachineController must be a child of CharacterBody3D.")
		return

	# Set a new random target position
	set_random_target(character)

	# Assign target and return state to the delegated pathfind state
	pathfind_state.target_node = $Marker3D
	pathfind_state.fallback_state = fallback_state

	# Transition to pathfinding
	state_machine_controller.set_state(pathfind_state)

# Called when exiting the wander state
func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)
	print("Exiting WanderState")

	var character: CharacterBody3D = state_machine_controller.get_parent() as CharacterBody3D
	if character != null:
		character.velocity = Vector3.ZERO

# Recursively sets a random position within range
func set_random_target(character: CharacterBody3D) -> void:
	random_position = character.global_position + Vector3(
		randf_range(-wander_range.y, wander_range.y),
		0.0,
		randf_range(-wander_range.y, wander_range.y)
	)

	# Retry if it's too close to current position
	if character.global_position.distance_to(random_position) < wander_range.x:
		set_random_target(character)
	else:
		$Marker3D.global_position = random_position

# Optional per-frame update
func update_state(delta: float, state_machine_controller: StateMachineController) -> void:
	pass
