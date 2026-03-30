@tool
extends FSMTransition

@onready var grounded_timer: Timer = %GroundedTimer

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not grounded_timer.is_stopped():
		return false

	return actor.is_on_floor()

