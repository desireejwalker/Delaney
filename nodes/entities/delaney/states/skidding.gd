@tool
extends FSMState

const SPEED_RETAINED_PERCENTAGE: float = 0.5

@onready var _skid_timer: Timer = %SkidTimer
@onready var _skid_cooldown_timer: Timer = %SkidCooldownTimer

func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var velocity = _handle_skidding(actor.velocity)
	actor.velocity = velocity
	
	_skid_timer.timeout.connect(_on_skid_timer_timeout)
	_skid_timer.start()

func _on_update(_delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if not _skid_timer.is_stopped():
		return
	
	actor.velocity = Vector3.ZERO
	_handle_transition_events(actor, blackboard)

func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	_skid_timer.timeout.disconnect(_on_skid_timer_timeout)

func _handle_skidding(current_velocity: Vector3) -> Vector3:
	var velocity = Vector3(
		current_velocity.x * SPEED_RETAINED_PERCENTAGE,
		0,
		current_velocity.z * SPEED_RETAINED_PERCENTAGE)
	
	return velocity

func _handle_transition_events(actor: Node, blackboard: Blackboard):
	if Input.is_action_pressed("move"):
		if Input.is_action_pressed("run"):
			get_parent().fire_event("skidding/on_start_running")
			return

		blackboard.remove_value("is_skidding_allowed_while_running")
		get_parent().fire_event("skidding/on_start_walking")
		return 
	
	blackboard.remove_value("is_skidding_allowed_while_running")
	get_parent().fire_event("skidding/on_start_idling")
	return

func _on_skid_timer_timeout():
	_skid_cooldown_timer.start()
