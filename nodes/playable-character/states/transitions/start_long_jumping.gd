@tool
extends FSMTransition

@onready var slide_limit_timer: Timer = %SlideLimitTimer

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not actor.is_on_floor():
		return false
	if not slide_limit_timer.is_stopped():
		return false
	
	return Input.is_action_pressed("jump")
