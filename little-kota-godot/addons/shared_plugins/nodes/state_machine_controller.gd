@icon("res://addons/shared_plugins/icons/state_machine_controller.svg")
extends Node
## Simple state machine controller.
class_name StateMachineController

signal state_changed

@export var current_state : CharacterState
@export var state_node : Node
@export var verbose : bool

func _ready() -> void:
	if verbose:
		connect("state_changed", print_state)
	set_state(current_state)

func print_state():
	print(current_state)

## Handle switching states
func set_state(new_state: CharacterState) -> void:
	if current_state:
		current_state.exit_state(self)
	current_state = new_state
	if current_state:
		current_state.enter_state(self)
	emit_signal("state_changed")

func _physics_process(delta: float) -> void:
	current_state.update_physics_state(delta, self)

func _process(delta: float) -> void:
	#print(current_state)
	current_state.update_state(delta, self)
