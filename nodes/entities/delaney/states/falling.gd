@tool
extends FSMState

const GRAVITY: float = 9.8
const ACCELERATION: int = 40

func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	pass

func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var velocity = _handle_falling(actor.velocity, delta)
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
	if actor.is_on_floor():
		get_parent().fire_event("falling/on_landing")
		return true
	
	if Input.is_action_pressed("spin") and not get_parent().last_active_state == %ArialHammerLaunching:
		get_parent().fire_event("falling/on_start_arial_hammer_launching")
		return true
	
	if actor.is_on_wall_only() and not (get_parent().last_active_state == %Wallrunning):
		get_parent().fire_event("falling/on_start_wallrunning")
		return true
	
	if Input.is_action_just_pressed("dive") and not get_parent().last_active_state == %Diving:
		get_parent().fire_event("falling/on_dive")
		return true
	
	return false

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	return velocity
