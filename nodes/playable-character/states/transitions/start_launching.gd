@tool
extends FSMTransition

# Components

@onready var flow_state_finite_state_machine: PlayableCharacterFiniteStateMachine = %PlayableCharacterFlowStateFiniteStateMachine
@onready var arial_hammer_launch_delay_timer: Timer = %ArialHammerLaunchDelayTimer

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if get_parent() == %ArialHammerLaunching:
		return _handle_arial_hammer_launching_state_case(actor)
	if not actor.is_on_floor():
		return false
	if flow_state_finite_state_machine.finite_state_machine.active_state == %Blunt:
		return false
	
	return Input.is_action_just_released("spin")

func _handle_arial_hammer_launching_state_case(_actor: PlayableCharacter) -> bool:
	return arial_hammer_launch_delay_timer.is_stopped()