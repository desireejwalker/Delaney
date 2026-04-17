@tool
extends FSMTransition

const ARIAL_ACTIONS_STRING: String = "arial_actions"
const DIVE_STATE_SEARCH_DEPTH: int = 3

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if actor.is_on_floor():
		return false
	if blackboard.get_value(ARIAL_ACTIONS_STRING) != null:
		var arial_actions: Array = blackboard.get_value(ARIAL_ACTIONS_STRING)
		var last_part = arial_actions
		if last_part.size() > DIVE_STATE_SEARCH_DEPTH:
			last_part = arial_actions.slice(arial_actions.size() - DIVE_STATE_SEARCH_DEPTH)
		if last_part.has(next_state.name):
			return false

	
	return Input.is_action_just_pressed("dive")