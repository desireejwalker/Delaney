@tool
extends FSMState

const HORIZONTAL_FORCE: float = 20.0
const VERTICAL_FORCE: float = 7.5
const GRAVITY: float = 9.8
const ACCELERATION: int = 40
const MAX_HORIZONTAL_VELOCITY: float = 20.0

@onready var _grounded_timer: Timer = %GroundedTimer

func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var direction = _handle_direction_input(actor)
	if direction.is_zero_approx():
		direction = actor.velocity.normalized()
	var velocity = _handle_long_jump_force(direction)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var horizontal_velocity_normalized = horizontal_velocity.normalized()
	
	actor.velocity = velocity
	if not horizontal_velocity.is_zero_approx():
		actor.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	_grounded_timer.start()

func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var direction = _handle_direction_input(actor)
	var speed = actor.get_entity_stats().get_agility() * 0.6
	var velocity = _handle_long_jumping(actor.velocity, direction, speed, delta)
	
	actor.velocity = velocity
	
	var transitioned = _handle_transition_events(actor, blackboard)
	if transitioned:
		return

func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node, blackboard: Blackboard) -> bool:
	if Input.is_action_just_pressed("dive"):
		get_parent().fire_event("long_jumping/on_dive")
		return true
	
	if actor.velocity.y < 0:
		get_parent().fire_event("long_jumping/on_start_falling")
		return true
	
	if not _grounded_timer.is_stopped():
		return false
	
	if actor.is_on_floor():
		get_parent().fire_event("long_jumping/on_landing")
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

func _handle_long_jump_force(direction: Vector3) -> Vector3:
	var horizontal_velocity = Vector3(
		direction.x * HORIZONTAL_FORCE,
		0.0,
		direction.z * HORIZONTAL_FORCE).limit_length(MAX_HORIZONTAL_VELOCITY)
	var vertical_velocity = Vector3.UP * VERTICAL_FORCE
	var velocity = horizontal_velocity + vertical_velocity
	
	return velocity

func _handle_long_jumping(current_velocity: Vector3, direction: Vector3, speed: float, delta) -> Vector3:
	var horizontal_velocity = direction * speed
	if direction.is_zero_approx():
		horizontal_velocity = current_velocity.normalized() * speed
	var velocity = current_velocity.move_toward(horizontal_velocity + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	
	return velocity
