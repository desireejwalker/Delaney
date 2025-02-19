@tool
extends FSMState

const ACCELERATION: int = 17
const SKID_THRESHOLD: float = -0.5

@onready var _skid_cooldown_timer: Timer = %SkidCooldownTimer

var _time_elapsed: float = 0.0

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)
	
	_time_elapsed = 0.0

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("on_jump")
		return
	
	if not actor.is_on_floor():
		get_parent().fire_event("on_start_falling")
		return
	
	if Input.is_action_pressed("slide"):
		get_parent().fire_event("on_start_sliding")
	
	if not Input.is_action_pressed("run"):
		get_parent().fire_event("on_start_walking")
		return
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	if _time_elapsed >= 3.0:
		if direction.is_zero_approx():
			get_parent().fire_event("on_start_skidding")
			return
		
		var dot = actor.velocity.normalized().dot(direction)
		if dot <= SKID_THRESHOLD:
			get_parent().fire_event("on_start_skidding")
			return
	
	actor.velocity = actor.velocity.move_toward(direction * actor.get_entity_stats().get_agility() * 1.5, ACCELERATION * delta)
	
	_time_elapsed = _time_elapsed + delta
	
	if actor.velocity.is_zero_approx():
		get_parent().fire_event("on_start_idling")
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
