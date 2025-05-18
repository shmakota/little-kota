extends Node

@onready var button = $Button
@onready var file_dialog = $FileDialog
@onready var model_root = $ModelRoot

func _ready():
	button.pressed.connect(_on_button_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.filters = ["*.pck ; PCK Files"]

func _on_button_pressed():
	file_dialog.popup_centered()

func _on_file_selected(path: String) -> void:
	if path.get_extension().to_lower() != "pck":
		print("❌ Please select a .pck file")
		return

	var filename = path.get_file()
	var dest_path = "user://" + filename
	var abs_dest_path = ProjectSettings.globalize_path(dest_path)

	# Copy PCK file to user:// folder
	if not copy_file(path, abs_dest_path):
		print("❌ Failed to copy PCK file")
		return

	print("✅ PCK copied to user://")

	# Mount the PCK
	if not load_pck(dest_path):
		print("❌ Failed to mount PCK")
		return

	print("✅ PCK mounted successfully")

	# Now load a known model path inside the PCK
	var model_path = "res://models/stone_pack.glb"  # change to your model's path inside PCK
	var model_resource = ResourceLoader.load(model_path)
	if model_resource == null:
		print("❌ Failed to load model from PCK at: ", model_path)
		return

	# Clear previous model(s)
	for child in model_root.get_children():
		child.queue_free()

	var instance = model_resource.instantiate()
	model_root.add_child(instance)
	print("✅ Model instanced from PCK")

func copy_file(src_path: String, dst_path: String) -> bool:
	var src = FileAccess.open(src_path, FileAccess.READ)
	if src == null:
		print("❌ Cannot open source file")
		return false
	var dst = FileAccess.open(dst_path, FileAccess.WRITE)
	if dst == null:
		print("❌ Cannot open destination file")
		src.close()
		return false
	dst.store_buffer(src.get_buffer(src.get_length()))
	src.close()
	dst.close()
	return true

func load_pck(pck_path: String) -> bool:
	var success = ProjectSettings.load_resource_pack(pck_path)
	if success:
		print("Mounted PCK:", pck_path)
	else:
		print("Failed to mount PCK:", pck_path)
	return success
