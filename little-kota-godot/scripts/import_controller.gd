extends Node

@export var button : Button
@export var file_dialog : FileDialog
@export var model_root : Node3D
@export var ui : Control


@export var ollama_api : OllamaAPI

func _on_button_pressed():
	print("pressed")
	file_dialog.popup_centered()

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


func _on_file_dialog_file_selected(path: String) -> void:
	print("selected")
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
	var model_path = "res://avatars/" + filename.get_basename() + "/" + filename.get_basename() + ".tscn"  # change to your model's path inside PCK
	var model_resource = ResourceLoader.load(model_path)
	if model_resource == null:
		print("❌ Failed to load model from PCK at: ", model_path)
		return

	# Clear previous model(s)
	for child in model_root.get_children():
		child.queue_free()

	var instance = model_resource.instantiate()
	model_root.add_child(instance)
	
	var model_name = instance.character_data.character_name
	var model_desc = instance.character_data.character_description
	print("[Loaded Avatar]")
	print("Name:" + model_name)
	print("Description:" + model_desc)
	ui.get_node("SystemPromptEdit").text = model_desc
	
	ollama_api.system_prompt = "[" + model_name + "]: " + model_desc
	ollama_api.reset_chat_history()
	
	print("✅ Model instanced from PCK")
