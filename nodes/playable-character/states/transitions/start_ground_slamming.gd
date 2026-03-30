@tool
extends FSMTransition

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if actor.is_on_floor():
		return false
	
	return Input.is_action_just_pressed("slam")
