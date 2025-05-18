extends Resource
class_name WeaponStats

@export var name : String
@export var weapon_model : PackedScene
@export var autofire : bool = false
@export var cooldown_time = 0.01  # Example cooldown time
var cooldown_timer = 0.0
@export var max_ammo = 0  # Example cooldown time
var ammo = 0
@export var animation_set : String
