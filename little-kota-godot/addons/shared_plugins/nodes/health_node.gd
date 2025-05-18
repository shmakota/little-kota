@icon("res://addons/shared_plugins/icons/health_icon.svg")
extends Node
## Needs to be added to the MultiplayerSynchronizer of a prop.
class_name Health

enum DamageTypes{BASE}

signal damaged

## Maximum health of the object.
@export var max_health : int = 0
## Set automatically. You can ignore this.
var health = 0

func _ready() -> void:
	health = max_health

@rpc("any_peer", "call_local")
func die():
	get_parent().queue_free()

@rpc("any_peer", "call_local")
func take_damage(dmg, damage_type, source = 0):
	match damage_type:
		DamageTypes.BASE:
			health -= dmg
			emit_signal("damaged")
			if find_child("Damage"):
				$Damage.stop()
				$Damage.play()
			print_debug("just damaged. new hp: " + str(health))
			if health <= 0:
				rpc("die")
				die()
