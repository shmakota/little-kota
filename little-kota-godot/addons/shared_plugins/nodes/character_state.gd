@icon("res://addons/shared_plugins/icons/character_state.svg")
extends Node
##A character state used in a StateMachineCharacter.
class_name CharacterState
@export var fallback_state : CharacterState

## A list of functions to check for alternative states. Examples would be: panic when x enemy nearby or check nearby for item, then pickup and return to previous state
@export var state_triggers : Array[CharacterStateTrigger]

# Method to handle what happens when entering this state.
##First entered state
func enter_state(state_machine_controller : StateMachineController) -> void:
	#print_debug("Entering state: ", self)
	for trigger in state_triggers:
		trigger.enter_state_trigger(state_machine_controller)

# Method to handle what happens when exiting this state.
##Exited state
func exit_state(state_machine_controller : StateMachineController) -> void:
	#print_debug("Exiting state: ", self)
	for trigger in state_triggers:
		trigger.exit_state_trigger(state_machine_controller)

# Update function that can be overridden by specific states.
##Updated on physics frame
func update_physics_state(delta : float, state_machine_controller : StateMachineController) -> void:
	pass

func handle_triggers(delta : float, state_machine_controller : StateMachineController) -> void:
	for trigger in state_triggers:
		var RESULT = await(trigger.update_physics_state_trigger(delta, state_machine_controller))
		if RESULT == trigger.TriggerResults.SUCCESS:
			state_machine_controller.set_state(trigger.trigger_state)
		elif RESULT == trigger.TriggerResults.FAILURE:
			state_machine_controller.set_state(fallback_state)

# Update function that can be overridden by specific states.
##Updated on frame (not currently used)
func update_state(delta : float, state_machine_controller : StateMachineController) -> void:
	handle_triggers(delta, state_machine_controller)
