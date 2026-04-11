@tool
extends FSMTransition

@onready var flow_state_finite_state_machine: PlayableCharacterFiniteStateMachine = %PlayableCharacterFlowStateFiniteStateMachine
@onready var launch_timer: Timer = %LaunchTimer
@onready var arial_hammer_launch_delay_timer: Timer = %ArialHammerLaunchDelayTimer

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if get_parent() == %ArialHammerLaunching:
		return _handle_arial_hammer_launching_state_case(actor)
	if get_parent() == %Launching:
		return _handle_launch_state_case(actor)
	if get_parent() == %WallRunning:
		return _handle_wall_running_state_case(actor)
	if get_parent() == %Jumping or \
	   get_parent() == %LongJumping or \
	   get_parent() == %WallJumping or \
	   get_parent() == %Diving or \
	   get_parent() == %HammerPogoing:
		return _handle_jumping_state_case(actor)
	if get_parent() == %GroundSlamming:
		return _handle_ground_slamming_state_case(actor)

	return not actor.is_on_floor()

func _handle_arial_hammer_launching_state_case(actor: PlayableCharacter):
	if Input.is_action_pressed("spin"):
		return false
	return not arial_hammer_launch_delay_timer.is_stopped()
func _handle_launch_state_case(actor: PlayableCharacter):
	if launch_timer.is_stopped():
		return true

	var launch_parameters = flow_state_finite_state_machine.finite_state_machine.active_state.launch_parameters
	var collision = actor.get_last_slide_collision()
	if not collision:
		return false
	return not launch_parameters.does_ricochet()
func _handle_wall_running_state_case(actor: PlayableCharacter):
	return not actor.is_on_wall_only()
func _handle_jumping_state_case(actor: PlayableCharacter):
	if actor.velocity.y > 0:
		return false
	return not actor.is_on_floor()
func _handle_ground_slamming_state_case(actor: PlayableCharacter):
	if actor.velocity.y < 0:
		return false
	return not actor.is_on_floor()