extends Button

@export var state_machine_controller : StateMachineController
@export var state : CharacterState

func _on_pressed() -> void:
	state_machine_controller.set_state(state)
