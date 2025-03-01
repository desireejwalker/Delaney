@tool
extends FSMState

const ACCELERATION: int = 5
const BOOST_FORCE: float = 1.6
const MAX_HORIZONTAL_VELOCITY: float = 20.0
const SPEED_WITHOUT_INPUT: float = 0.2

@onready var _slide_limit_timer: Timer = %SlideLimitTimer

func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	# give delaney a boost of speed when she starts sliding
	# if she's not landing to keep from gaining exponential speed
	# via holding W, Shift, C and Spacebar.
	if not get_parent().last_active_state == %Landing:
		var velocity = _handle_slide_force(actor.velocity)
		actor.velocity = velocity
	#if not get_parent().last_active_state == %LongJumping:
		_slide_limit_timer.start()

func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var direction = _handle_direction_input(actor)
	var speed = actor.get_entity_stats().get_agility()
	var velocity = _handle_sliding(actor.velocity, direction, speed, delta)
	var velocity_normalized = velocity.normalized()
	
	actor.velocity = velocity
	if velocity_normalized.is_zero_approx():
		actor.rotation.y = atan2(velocity_normalized.x, velocity_normalized.z)
	
	var transitioned = _handle_transition_events(actor)
	if transitioned:
		return

func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node) -> bool:
	if not actor.is_on_floor():
		get_parent().fire_event("sliding/on_start_falling")
		return true
	
	if not _slide_limit_timer.is_stopped():
		if Input.is_action_pressed("jump"):
			get_parent().fire_event("sliding/on_start_long_jump")
			return true
		return false
	
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("sliding/on_jump")
		return true
	
	if not Input.is_action_pressed("slide"):
		if actor.velocity.is_zero_approx():
			get_parent().fire_event("sliding/on_start_idling")
			return true

		if Input.is_action_pressed("run"):
			get_parent().fire_event("sliding/on_start_running")
			return true
		else:
			get_parent().fire_event("sliding/on_start_walking")
			return true
	
	return false

func _handle_slide_force(current_velocity: Vector3) -> Vector3:
	var velocity = Vector3(
		current_velocity.x * BOOST_FORCE,
		0,
		current_velocity.z * BOOST_FORCE
	).limit_length(MAX_HORIZONTAL_VELOCITY)
	return velocity

func _handle_direction_input(actor: Node) -> Vector3:
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	return direction

func _handle_sliding(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		# if no input from player, delaney will slowly approach a max speed of SPEED_WITHOUT_INPUT
		velocity = current_velocity.move_toward((current_velocity.limit_length(SPEED_WITHOUT_INPUT) * speed), ACCELERATION * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed), ACCELERATION * delta)
	
	return velocity
