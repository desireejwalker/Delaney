@tool
extends FSMState

const WALL_PUSH_FORCE: float = 14
const FORCE: float = 12.5
const GRAVITY: float = 9.8
const ACCELERATION: int = 40

@onready var _grounded_timer: Timer = %GroundedTimer

func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var velocity = _handle_wall_jump_force(actor.velocity, blackboard.get_value("current_wall_normal"))
	actor.velocity = velocity
	
	_grounded_timer.start()

func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var direction = _handle_direction_input(actor)
	var velocity = _handle_wall_jump(
		actor.velocity,
		direction,
		actor.get_entity_stats().get_agility() * 0.8,
		delta)
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var horizontal_velocity_normalized = horizontal_velocity.normalized()
	
	actor.velocity = velocity
	if not horizontal_velocity_normalized.is_zero_approx():
		actor.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	var transitioned = _handle_transition_events(actor, blackboard)
	if transitioned:
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node, blackboard: Blackboard) -> bool:
	if Input.is_action_just_pressed("dive"):
		get_parent().fire_event("wall_jumping/on_dive")
		return true
	
	if actor.velocity.y < 0:
		get_parent().fire_event("wall_jumping/on_start_falling")
		return true
	
	if not _grounded_timer.is_stopped():
		if actor.is_on_floor():
			get_parent().fire_event("wall_jumping/on_landing")
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

func _handle_wall_jump_force(current_velocity: Vector3, current_wall_normal: Vector3) -> Vector3:
	var wall_push = current_wall_normal * WALL_PUSH_FORCE
	var velocity = current_velocity + (Vector3.UP * FORCE) + wall_push
	
	return velocity

func _handle_wall_jump(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed) + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	
	return velocity
