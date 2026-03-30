@tool
extends FSMTransition


# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if actor.is_on_floor():
		return false
	if get_parent().get_parent().last_active_state == %Launching:
		return false
	
	return Input.is_action_pressed("spin")