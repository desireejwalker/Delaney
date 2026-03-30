@tool
extends FSMState

const IS_MOVING: String = "is_moving"
const IS_SKIDDING_ALLOWED_WHILE_RUNNING: String = "is_skidding_allowed_while_running"

@export var acceleration: float = 20
@export var speed: float = 40

# Components

@onready var running_dust_trail: GPUParticles3D = %RunningDustTrail
@onready var allow_skidding_delay_timer: Timer = %AllowSkiddingDelayTimer


# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	blackboard.set_value(IS_MOVING, true)
	
	allow_skidding_delay_timer.timeout.connect(_on_allow_skidding_delay_timer_timeout)
	if allow_skidding_delay_timer.paused:
		allow_skidding_delay_timer.paused = false
		return
	allow_skidding_delay_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	var direction = actor.get_input_direction()
	var velocity = _handle_running(actor.velocity, direction, delta)
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	running_dust_trail.emitting = false
	
	allow_skidding_delay_timer.timeout.disconnect(_on_allow_skidding_delay_timer_timeout)
	if not allow_skidding_delay_timer.is_stopped():
		allow_skidding_delay_timer.paused = true

func _handle_running(current_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(direction * speed, acceleration * delta)
	return velocity

func _on_allow_skidding_delay_timer_timeout():
	running_dust_trail.emitting = true
