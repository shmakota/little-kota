@icon("res://addons/shared_plugins/icons/character_state.svg")
extends CharacterStateTrigger
## A trigger that switches to a random state based on weighted chance.
class_name RandomStateTrigger

@export var random_chance: int = 200
@export var random_states: Dictionary = {}

func update_physics_state_trigger(delta: float, state_machine_controller: StateMachineController) -> TriggerResults:
	if random_states.size() == 0 or random_chance <= 0:
		return TriggerResults.FAILURE

	var chance: int = randi_range(1, random_chance)
	if chance != 1:
		return TriggerResults.FAILURE

	var selected_state: CharacterState = pick_random_weighted_state()
	if selected_state != null:
		state_machine_controller.set_state(selected_state)
		return TriggerResults.NULL
	
	return TriggerResults.FAILURE

func pick_random_weighted_state() -> CharacterState:
	var total_weight: int = 0
	for state in random_states.keys():
		total_weight += int(random_states[state])

	if total_weight == 0:
		return null

	var roll = randi_range(1, total_weight)
	var running_total = 0

	for state in random_states.keys():
		running_total += int(random_states[state])
		if roll <= running_total:
			return get_node(state)

	return null
