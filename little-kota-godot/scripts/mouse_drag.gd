extends Node3D

@export var camera: Camera3D
var picked_object: Node3D = null
var drag_offset: Vector3 = Vector3.ZERO
var drag_plane: Plane

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			try_pick_object(event.position)
		else:
			release_object()
	elif event is InputEventMouseMotion and picked_object:
		drag_object(event.position)

func try_pick_object(mouse_pos: Vector2) -> void:
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 1  # Adjust if needed
	query.exclude = []

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result.has("collider"):
		var collider = result["collider"]
		if collider.is_in_group("draggable"):
			print("drag")
			picked_object = collider
			var hit_pos: Vector3 = result["position"]
			drag_plane = Plane(camera.global_transform.basis.z, hit_pos)
			drag_offset = picked_object.global_transform.origin - hit_pos

func release_object() -> void:
	picked_object = null

func drag_object(mouse_pos: Vector2) -> void:
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)
	var intersection = drag_plane.intersects_ray(from, dir)
	if intersection != null:
		picked_object.global_transform.origin = intersection + drag_offset
