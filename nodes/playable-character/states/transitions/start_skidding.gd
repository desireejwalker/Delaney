@tool
extends FSMTransition

const SKID_THRESHOLD: float = -0.5

@onready var allow_skidding_delay_timer: Timer = %AllowSkiddingDelayTimer
@onready var skid_cooldown_timer: Timer = %SkidCooldownTimer

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter
	
	if not skid_cooldown_timer.is_stopped():
		return false
	if not allow_skidding_delay_timer.is_stopped():
		return false
	
	var input_direction = actor.get_input_direction()
	var dot = actor.velocity.normalized().dot(input_direction)
	
	return input_direction.is_zero_approx() or dot <= SKID_THRESHOLD
	


