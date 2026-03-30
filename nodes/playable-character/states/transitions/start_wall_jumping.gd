@tool
extends FSMTransition

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if not actor.is_on_wall_only():
		return false
	
	return Input.is_action_pressed("jump")
