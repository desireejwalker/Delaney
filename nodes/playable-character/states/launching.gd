@tool
extends FSMState

const CURRENT_LAUNCH_TRAJECTORY: String = "current_launch_trajectory"
const ARIAL_ACTIONS_STRING: String = "arial_actions"

var launch_parameters: LaunchParameters
var trail_instance: Node3D

# Components

@onready var flow_state_finite_state_machine: PlayableCharacterFiniteStateMachine = %PlayableCharacterFlowStateFiniteStateMachine
@onready var collider: CollisionShape3D = %PlayableCharacterCollider
# @onready var hammer: Node3D = %Hammer
@onready var launch_timer: Timer = %LaunchTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	actor.character_container.visible = false
	# _hammer.visible = false
	
	launch_parameters = flow_state_finite_state_machine.finite_state_machine.active_state.launch_parameters
	trail_instance = launch_parameters.get_trail_particle_system().instantiate()
	actor.add_child(trail_instance)
	
	_update_arial_actions(blackboard)
	var trajectory = blackboard.get_value(CURRENT_LAUNCH_TRAJECTORY)
	actor.mover.set_velocity(trajectory)
	
	if launch_parameters.does_ricochet():
		actor.mover.do_move_and_slide = false
	
	launch_timer.start(launch_parameters.get_duration_seconds())

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var collision = actor.get_last_slide_collision()
	if launch_parameters.does_ricochet():
		collision = actor.move_and_collide(actor.velocity * delta)
	var velocity = _handle_ricochet(actor, collision)

	actor.mover.set_velocity(velocity)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	actor.mover.do_move_and_slide = true
	
	actor.character_container.visible = true
	# hammer.visible = true
	
	blackboard.set_value(CURRENT_LAUNCH_TRAJECTORY, null)
	
	trail_instance.get_node("%AnimationPlayer").play("self_destruct")

func _handle_ricochet(actor: Node, collision: KinematicCollision3D) -> Vector3:
	actor = actor as PlayableCharacter
	if not launch_parameters.does_ricochet():
		return actor.velocity
	if not collision:
		return actor.velocity
	
	return actor.velocity.bounce(collision.get_normal())

func _update_arial_actions(blackboard: Blackboard):
	if blackboard.get_value(ARIAL_ACTIONS_STRING) == null:
		blackboard.set_value(ARIAL_ACTIONS_STRING, [name])
		return
	blackboard.get_value(ARIAL_ACTIONS_STRING).append(name)