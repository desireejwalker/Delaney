@tool
extends FSMState

const WALL_PULL_FORCE: int = 1
const GRAVITY: float = 2
const ACCELERATION: int = 40
const VERTICAL_STAMINA_MAX: float = 5.0
const VERTICAL_SPEED: float = 6.5

var _vertical_stamina = VERTICAL_STAMINA_MAX

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	blackboard.set_value("is_moving", true)
	
	var last_slide_collision = actor.get_last_slide_collision()
	if not last_slide_collision:
		get_parent().fire_event("wallrunning/on_start_falling")
		return
	
	blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())
	
	_vertical_stamina = VERTICAL_STAMINA_MAX

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity

	if Input.is_action_just_pressed("jump"):
		get_parent().fire_event("wallrunning/on_wall_jump")
	
	if not actor.is_on_wall_only():
		get_parent().fire_event("wallrunning/on_start_falling")
		return
	
	var wall_pull = -blackboard.get_value("current_wall_normal") * WALL_PULL_FORCE
	var gravity = -GRAVITY
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	var horizontal_speed = 1.5
	var dot = wall_pull.normalized().dot(direction)
	
	horizontal_speed = remap(dot, 0, 1, 2.2, 1.5)
	var vertical_speed = gravity + dot * VERTICAL_SPEED
	if _vertical_stamina <= 0:
		dot = remap(dot, -1, 1, -1, 0)
		vertical_speed = gravity + dot * VERTICAL_SPEED
	
	var velocity = actor.velocity.move_toward(
		Vector3(
			float(direction.x * actor.get_entity_stats().get_agility() * horizontal_speed),
			vertical_speed,
			float(direction.z * actor.get_entity_stats().get_agility() * horizontal_speed)),
		ACCELERATION * delta) + wall_pull
	
	# decrease vertical stamina while velocity is positive
	if velocity.y > 0:
		_vertical_stamina = _vertical_stamina - (velocity.y * delta)
		print(_vertical_stamina)
	
	actor.velocity = velocity
	
	var horizontal_velocity = Vector3(actor.velocity.x, 0, actor.velocity.z)
	var horizontal_velocity_normalized = horizontal_velocity.normalized()
	if not horizontal_velocity.is_zero_approx():
		actor.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	blackboard.set_value("current_wall_normal", actor.get_last_slide_collision().get_normal())

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: Blackboard) -> void:
	pass
