extends CharacterState
## Camera idle state using a Marker3D position and rotation
class_name CameraIdleState

## Speed at which camera moves to idle position
@export var move_speed: float = 5.0
## Speed at which camera rotates to idle orientation
@export var rotation_speed: float = 5.0

@export var idle_position: Marker3D

func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	
	if idle_position == null:
		push_error("CameraIdleState: 'IdlePosition' Marker3D is not assigned!")

func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)

func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	var camera = state_machine_controller.get_parent()

	if idle_position:
		# Interpolate position
		var target_pos = idle_position.global_transform.origin
		camera.global_transform.origin = camera.global_transform.origin.lerp(target_pos, move_speed * delta)

		# Interpolate rotation
		var current_basis = camera.global_transform.basis
		var target_basis = idle_position.global_transform.basis
		camera.global_transform.basis = current_basis.slerp(target_basis, rotation_speed * delta)

func update_state(delta: float, state_machine_controller: StateMachineController) -> void:
	super.update_state(delta, state_machine_controller)
