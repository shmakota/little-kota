@icon("res://addons/shared_plugins/icons/interaction.svg")
extends StaticBody3D
class_name InteractionObject

signal interacted_with

@export var interaction_name : String
@export var call_interact : bool = false

func _physics_process(delta: float) -> void:
	if call_interact:
		print("CALLING INTERACTION ON " + str(self) + " FROM EDITOR")
		call_interact = false
		interact(1)
		#rpc("interact", null)

## Source is an int referring to the player's ID.
func interact(source : int):
	emit_signal("interacted_with")
	print_debug("interact")
	pass
