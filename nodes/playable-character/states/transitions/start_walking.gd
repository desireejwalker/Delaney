@tool
extends FSMTransition

# Components

@onready var flow_state_finite_state_machine: PlayableCharacterFiniteStateMachine = %PlayableCharacterFlowStateFiniteStateMachine

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if not actor.is_on_floor():
		return false
	if Input.is_action_pressed("run"):
		return false
	if Input.is_action_just_released("spin"):
		if flow_state_finite_state_machine.finite_state_machine.active_state == %Blunt:
			return not actor.get_input_direction().is_zero_approx() or not actor.velocity.is_zero_approx()
	if Input.is_action_pressed("slide") || Input.is_action_pressed("spin"):
		return false

	return not actor.get_input_direction().is_zero_approx() or not actor.velocity.is_zero_approx()
