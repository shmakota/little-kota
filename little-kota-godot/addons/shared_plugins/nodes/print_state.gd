extends CharacterState

##Updated on physics frame
func update_physics_state(delta : float, state_machine_controller : StateMachineController) -> void:
	super.update_physics_state(delta, state_machine_controller)
	#print(name + str(state_machine_controller.state_node.visible))
