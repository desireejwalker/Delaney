@tool
extends FSMState

const ACCELERATION: int = 25

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("on_jump")
		return
	
	if not actor.is_on_floor():
		get_parent().fire_event("on_start_falling")
		return
	
	if Input.is_action_pressed("run"):
		get_parent().fire_event("on_start_running")
		return
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	actor.velocity = actor.velocity.move_toward(direction * actor.get_entity_stats().get_agility(), ACCELERATION * delta)
	
	if actor.velocity.is_zero_approx():
		get_parent().fire_event("on_start_idling")
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

#func _walk(delta, direction, speed, horizontal_velocity) -> Vector3:
	#horizontal_velocity = horizontal_velocity.lerp(direction * speed, ACCELERATION * delta)
	#
	#return horizontal_velocity
