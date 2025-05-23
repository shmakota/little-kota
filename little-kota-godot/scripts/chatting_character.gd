extends CharacterBody3D
class_name ChattingCharacter

@export var character_data : ChattingCharacterData
@export var playermodel : Node


# system prompt formatting
func _ready():
	# create advanced character prompt if not filled out
	if character_data.character_prompt == "":
		var filled_template = BaseGlobals.fill_commandments_template(
			BaseGlobals.raw_commandments_template,
			"User",
			character_data.character_personality,
			character_data.character_scenario,
			get_world_info_from_descriptors(),
			character_data.character_name
			)
		
		character_data.character_prompt = filled_template
	$StateMachineController/PlayerInputState/OllamaAPI.system_prompt = character_data.character_prompt
	$StateMachineController/PlayerInputState/OllamaAPI.reset_chat_history()

func get_world_info_from_descriptors() -> String:
	var descriptors = get_tree().get_nodes_in_group("spatial_descriptors")
	var descriptions = [character_data.character_world_info]
	for descriptor in descriptors:
		# Skip if it's a child of self
		if self.is_ancestor_of(descriptor):
			continue
		if descriptor.space_description != "":
			var type_str := ""
			match descriptor.space_type:
				SpatialDescriptor.SpaceTypes.OBJECT:
					type_str = "Object"
				SpatialDescriptor.SpaceTypes.AREA:
					type_str = "Area"
				SpatialDescriptor.SpaceTypes.ENTITY:
					type_str = "Entity"
				_:
					type_str = "Unknown"
			var desc_str = "%s NAMED %s DESCRIPTION: %s" % [type_str, descriptor.space_name, descriptor.space_description]
			descriptions.append(desc_str)
	return ", ".join(descriptions)
