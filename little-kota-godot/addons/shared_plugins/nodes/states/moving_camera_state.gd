extends CharacterState
class_name MovingCameraState

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 1.0
@export var use_input_for_rotation: bool = true

var yaw_deg := 0.0
var pitch_deg := 0.0
var camera: Camera3D = null

var capture_input = false

func enter_state(state_machine_controller: StateMachineController) -> void:
	super.enter_state(state_machine_controller)
	capture_input = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	camera = state_machine_controller.get_parent() as Camera3D
	if camera:
		var rot = camera.rotation_degrees
		yaw_deg = rot.y
		pitch_deg = rot.x

func exit_state(state_machine_controller: StateMachineController) -> void:
	super.exit_state(state_machine_controller)
	capture_input = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func update_physics_state(delta: float, state_machine_controller: StateMachineController) -> void:
	if camera == null:
		return

	var direction := Vector3.ZERO

	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	if Input.is_action_pressed("move_forward"):
		direction += forward
	if Input.is_action_pressed("move_backward"):
		direction -= forward
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_right"):
		direction += right
	if Input.is_action_pressed("ui_home"):
		state_machine_controller.set_state(fallback_state)

	if direction.length_squared() > 0:
		direction = direction.normalized()
		camera.global_translate(direction * move_speed * delta)

func update_state(delta: float, state_machine_controller: StateMachineController) -> void:
	if not use_input_for_rotation and camera:
		var mouse_delta = Input.get_last_mouse_velocity()
		apply_camera_rotation(mouse_delta)

func _input(event: InputEvent) -> void:
	if capture_input:
		if use_input_for_rotation and event is InputEventMouseMotion and camera:
			apply_camera_rotation(event.relative)

func apply_camera_rotation(mouse_delta: Vector2) -> void:
	yaw_deg -= mouse_delta.x * mouse_sensitivity
	pitch_deg -= mouse_delta.y * mouse_sensitivity
	pitch_deg = clamp(pitch_deg, -89, 89)

	# Convert to radians and apply with Basis
	var yaw_rad = deg_to_rad(yaw_deg)
	var pitch_rad = deg_to_rad(pitch_deg)

	camera.transform.basis = Basis(Vector3.UP, yaw_rad) * Basis(Vector3.RIGHT, pitch_rad)
