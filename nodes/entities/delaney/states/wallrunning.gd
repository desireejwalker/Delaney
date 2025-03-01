@tool
extends FSMState

const WALL_PULL_FORCE: int = 1
const GRAVITY: float = 2
const ACCELERATION: int = 40
const VERTICAL_STAMINA_MAX: float = 5.0
const VERTICAL_SPEED: float = 6.5
const HORIZONTAL_SPEED_MAX: float = 2.2
const HORIZONTAL_SPEED_MIN: float = 1.5

var _vertical_stamina = VERTICAL_STAMINA_MAX

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var last_slide_collision = actor.get_last_slide_collision()
	if not last_slide_collision:
		get_parent().fire_event("wallrunning/on_start_falling")
		return
	
	blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())
	
	_vertical_stamina = VERTICAL_STAMINA_MAX

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var last_slide_collision = actor.get_last_slide_collision()
	if not last_slide_collision:
		get_parent().fire_event("wallrunning/on_start_falling")
		return
	
	blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())
	var wall_negative_normal = -blackboard.get_value("current_wall_normal")
	var gravity = -GRAVITY
	var direction = _handle_direction_input(actor)
	
	var velocity = _handle_wallrunning(
		wall_negative_normal,
		actor.velocity,
		direction,
		actor.get_entity_stats().get_agility(),
		gravity,
		delta)
	
	# decrease vertical stamina while velocity is positive
	_vertical_stamina = _handle_stamina(velocity.y, delta)
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var horizontal_velocity_normalized = horizontal_velocity.normalized()
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		actor.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	var transitioned = _handle_transition_events(actor)
	if transitioned:
		return

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node) -> bool:
	if Input.is_action_just_pressed("jump"):
		get_parent().fire_event("wallrunning/on_wall_jump")
		return true
	
	if not actor.is_on_wall_only():
		get_parent().fire_event("wallrunning/on_start_falling")
		return true
	
	return false

func _handle_direction_input(actor: Node) -> Vector3:
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	return direction

func _handle_wallrunning(wall_negative_normal: Vector3, current_velocity: Vector3, direction: Vector3, speed: float, gravity: float, delta) -> Vector3:
	var wall_pull = wall_negative_normal * WALL_PULL_FORCE
	var dot = wall_negative_normal.dot(direction)
	var horizontal_speed = remap(dot, 0, 1, HORIZONTAL_SPEED_MAX, HORIZONTAL_SPEED_MIN) * speed
	
	var vertical_speed = gravity + dot * VERTICAL_SPEED
	if _vertical_stamina <= 0:
		dot = remap(dot, -1, 1, -1, 0)
		vertical_speed = gravity + dot * VERTICAL_SPEED
		
	var target_velocity = Vector3(
		float(direction.x * horizontal_speed),
		vertical_speed,
		float(direction.z * horizontal_speed))
	var velocity = current_velocity.move_toward(target_velocity, ACCELERATION * delta) + wall_pull
	
	return velocity

func _handle_stamina(velocity_y: float, delta: float):
	var vertical_stamina = _vertical_stamina
	if velocity_y > 0:
		vertical_stamina = vertical_stamina - (velocity_y * delta)
	
	return vertical_stamina
