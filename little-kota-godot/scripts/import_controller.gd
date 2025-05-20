extends Node

@export var file_dialog : FileDialog
@export var model_root : Node3D
@export var map_root : Node3D
@export var ui : Control
@export var ollama_api : OllamaAPI

var pending_load_type := "" # "character" or "map"

func _on_load_character_pressed():
	pending_load_type = "character"
	file_dialog.popup_centered()

func _on_load_map_pressed():
	pending_load_type = "map"
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(path: String) -> void:
	if path.get_extension().to_lower() != "pck":
		print("❌ Please select a .pck file")
		return

	match pending_load_type:
		"character":
			load_character_pck(path)
		"map":
			load_map_pck(path)
		_:
			print("❌ No load type selected.")
	pending_load_type = ""

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
		print("✅ Mounted PCK:", pck_path)
	else:
		print("❌ Failed to mount PCK:", pck_path)
	return success

func load_scene_from_pck(base_name: String, subdir: String) -> PackedScene:
	var scene_path = "res://" + subdir + "/" + base_name + "/" + base_name + ".tscn"
	var scene = ResourceLoader.load(scene_path)
	if scene == null:
		print("❌ Failed to load scene at:", scene_path)
	return scene

func load_character_pck(path: String) -> void:
	var filename = path.get_file()
	var base_name = filename.get_basename()
	var dest_path = "user://" + filename

	if not copy_file(path, ProjectSettings.globalize_path(dest_path)):
		print("❌ Failed to copy character PCK")
		return

	if not load_pck(dest_path):
		print("❌ Failed to mount character PCK")
		return

	var scene = load_scene_from_pck(base_name, "avatars")
	if scene == null:
		return

	for child in model_root.get_children():
		child.queue_free()

	var instance = scene.instantiate()
	model_root.add_child(instance)

	var model_name = instance.character_data.character_name
	var model_desc = instance.character_data.character_scenario
	var model_personality = instance.character_data.character_personality
	var model_prompt = instance.character_data.character_prompt

	print("[Loaded Avatar]")
	print("Name: " + model_name)
	print("Scenario: " + model_desc)
	print("Personality: " + model_personality)
	print("Prompt: " + model_prompt)

	ui.get_node("SystemPromptEdit").text = model_prompt
	ollama_api.system_prompt = model_prompt
	ollama_api.reset_chat_history()

	print("✅ Character instanced from PCK")

func load_map_pck(path: String) -> void:
	var filename = path.get_file()
	var base_name = filename.get_basename()
	var dest_path = "user://" + filename

	if not copy_file(path, ProjectSettings.globalize_path(dest_path)):
		print("❌ Failed to copy map PCK")
		return

	if not load_pck(dest_path):
		print("❌ Failed to mount map PCK")
		return

	var scene = load_scene_from_pck(base_name, "maps")
	if scene == null:
		return

	for child in map_root.get_children():
		child.queue_free()

	var instance = scene.instantiate()
	map_root.add_child(instance)

	print("✅ Map instanced from PCK:", base_name)


func _on_import_model_pressed() -> void:
	_on_load_character_pressed()


func _on_import_map_pressed() -> void:
	_on_load_map_pressed()
