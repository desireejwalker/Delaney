@tool
extends FSMState

const ACCELERATION: int = 25

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	pass

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var direction = _handle_direction_input(actor)
	var speed = actor.get_entity_stats().get_agility()
	var velocity = _handle_walking(actor.velocity, direction, speed, delta)
	var velocity_normalized = velocity.normalized()
	
	actor.velocity = velocity
	if velocity_normalized.is_zero_approx():
		return
	
	actor.rotation.y = atan2(velocity_normalized.x, velocity_normalized.z)
	
	var transitioned = _handle_transition_events(actor)
	if transitioned:
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node) -> bool:
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("walking/on_jump")
		return true
	
	if not actor.is_on_floor():
		get_parent().fire_event("walking/on_start_falling")
		return true
	
	if Input.is_action_pressed("spin"):
		get_parent().fire_event("walking/on_start_hammer_launching")
		return true
	
	if Input.is_action_pressed("run"):
		get_parent().fire_event("walking/on_start_running")
		return true
	
	if actor.velocity.is_zero_approx():
		get_parent().fire_event("walking/on_start_idling")
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

func _handle_walking(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(direction * speed, ACCELERATION * delta)
	return velocity
