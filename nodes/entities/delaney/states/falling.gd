@tool
extends FSMState

const GRAVITY: float = 9.8
const ACCELERATION: int = 40

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if Input.is_action_pressed("spin") and not get_parent().last_active_state == %ArialHammerLaunching:
		get_parent().fire_event("falling/on_start_arial_hammer_launching")
		return
	
	if actor.is_on_wall_only() and not (get_parent().last_active_state == %Wallrunning):
		get_parent().fire_event("falling/on_start_wallrunning")
		return
	
	if Input.is_action_just_pressed("dive") and not get_parent().last_active_state == %Diving:
		get_parent().fire_event("falling/on_dive")
		return
	
	actor.velocity = actor.velocity.move_toward(actor.velocity + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	var horizontal_velocity = Vector3(actor.velocity.x, 0, actor.velocity.z)
	var horizontal_velocity_normalized = horizontal_velocity.normalized()
	if not horizontal_velocity.is_zero_approx():
		actor.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	if actor.is_on_floor():
		get_parent().fire_event("falling/on_landing")
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
