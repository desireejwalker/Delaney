@tool
extends FSMState

const ACCELERATION: int = 5
const BOOST_FORCE: float = 1.6
const MAX_HORIZONTAL_VELOCITY: float = 20.0

@onready var _slide_limit_timer: Timer = %SlideLimitTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)
	
	actor = actor as DelaneyEntity
	
	if not get_parent().last_active_state == %Landing:
		actor.velocity = actor.velocity * BOOST_FORCE
		actor.velocity = actor.velocity.limit_length(MAX_HORIZONTAL_VELOCITY)
	
	_slide_limit_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if not actor.is_on_floor():
		get_parent().fire_event("sliding/on_start_falling")
		return
	
	if Input.is_action_pressed("jump") and not _slide_limit_timer.is_stopped():
		get_parent().fire_event("sliding/on_start_long_jump")
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	if direction.is_zero_approx():
		actor.velocity = actor.velocity.move_toward((actor.velocity.limit_length(0.2) * actor.get_entity_stats().get_agility()), ACCELERATION * delta)
	else:
		actor.velocity = actor.velocity.move_toward((direction * actor.get_entity_stats().get_agility()), ACCELERATION * delta)
	var velocity_normalized = actor.velocity.normalized()
	if not actor.velocity.is_zero_approx():
		actor.rotation.y = atan2(velocity_normalized.x, velocity_normalized.z)
	
	if not _slide_limit_timer.is_stopped():
		return
	
	if not Input.is_action_pressed("slide"):
		if actor.velocity.is_zero_approx():
			get_parent().fire_event("sliding/on_start_idling")
			return

		if Input.is_action_pressed("run"):
			get_parent().fire_event("sliding/on_start_running")
			return
		else:
			get_parent().fire_event("sliding/on_start_walking")
			return


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
