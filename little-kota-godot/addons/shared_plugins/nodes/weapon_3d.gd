@icon("res://addons/shared_plugins/icons/weapon.svg")
# end_attack and begin_attack need to be called from another script that handles input (probably should be the player)
extends Node3D
class_name Weapon3D

signal weapon_fired
signal weapon_stopped_firing

enum WeaponStates {SETUP, IDLE, BEGIN_FIRE, FIRING, AWAITING_COOLDOWN, END_FIRE}
var weapon_state : WeaponStates = WeaponStates.SETUP
@export var entity : CharacterBody3D
@export var raycast : RayCast3D = null
var equipped = false

@export var weapon_model : PackedScene
# Automatically swing when the mouse is held down.
@export var autofire : bool = false
@export var cooldown_time = 0.01  # Example cooldown time
var cooldown_timer = 0.0
@export var max_ammo = 0  # Example cooldown time
var ammo = 0
@export var animation_set : String

var weapon_model_path : NodePath

func _process(delta: float) -> void:
	_weapon_process(delta)

func _weapon_process(delta : float) -> void:
	pass

# Physics process, handles weapon states.
func _physics_process(delta: float) -> void:
	#print(cooldown_timer)
	cooldown_timer -= delta
	match weapon_state:
		WeaponStates.SETUP:
			reload_model()
			weapon_state = WeaponStates.IDLE
		
		WeaponStates.IDLE:
			pass
		
		WeaponStates.BEGIN_FIRE:
			if cooldown_timer <= 0.0:  # Ensure firing only starts when cooldown is finished
				weapon_state = WeaponStates.FIRING
			else:
				weapon_state = WeaponStates.AWAITING_COOLDOWN
		
		WeaponStates.FIRING:
			_weapon_firing(delta)
			cooldown_timer = cooldown_time  # Start cooldown after firing
			if autofire:
				weapon_state = WeaponStates.AWAITING_COOLDOWN  # Transition to cooldown after firing
			else:
				weapon_state = WeaponStates.END_FIRE
		
		WeaponStates.AWAITING_COOLDOWN:
			if cooldown_timer <= 0.0:
				weapon_state = WeaponStates.FIRING  # Return to firing after cooldown ends
		
		WeaponStates.END_FIRE:
			weapon_state = WeaponStates.IDLE

# Trigger the beginning of an attack.
func _begin_attack(entity) -> void:
	if cooldown_timer <= 0.0:  # Only start firing if cooldown is over
		weapon_state = WeaponStates.BEGIN_FIRE
		emit_signal("weapon_fired")  # Signal weapon fired here to start firing effects

# End the attack and emit the stop firing signal.
func _end_attack(entity) -> void:
	emit_signal("weapon_stopped_firing")  # Signal to stop firing effects
	weapon_state = WeaponStates.END_FIRE  # Transition to end fire state

# Handle the weapon firing logic.
func _weapon_firing(delta: float) -> void:
	# Example firing logic, add more behavior here like damaging targets, etc.
	print("pew")  # Placeholder firing sound or effect

func reload_model() -> void:
	for child in get_children():
		# clear old loaded weapon models
		child.queue_free()
	if weapon_model:
		var inst_weapon_model = weapon_model.instantiate()
		inst_weapon_model.set_multiplayer_authority(int(get_parent().get_parent().name))
		add_child(inst_weapon_model)
		weapon_model_path = inst_weapon_model.get_path()

func _equipped(entity) -> void:
	equipped = true

func _unequipped(entity) -> void:
	equipped = false
