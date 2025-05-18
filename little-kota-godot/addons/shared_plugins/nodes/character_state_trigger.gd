@icon("res://addons/shared_plugins/icons/character_state.svg")
extends Node
##A character state trigger used in a StateMachineCharacter.
class_name CharacterStateTrigger

@export var trigger_state : CharacterState

enum TriggerResults{FAILURE, SUCCESS}

func update_physics_state_trigger(delta : float, state_machine_controller : StateMachineController) -> TriggerResults:
	return TriggerResults.SUCCESS

func enter_state_trigger(state_machine_controller : StateMachineController) -> void:
	pass

func exit_state_trigger(state_machine_controller : StateMachineController) -> void:
	pass
