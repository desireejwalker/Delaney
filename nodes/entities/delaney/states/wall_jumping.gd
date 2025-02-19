@tool
extends FSMState

const WALL_PUSH_FORCE: float = 14
const FORCE: float = 12.5
const GRAVITY: float = 9.8
const ACCELERATION: int = 40

@onready var _grounded_timer: Timer = %GroundedTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)
	
	actor = actor as DelaneyEntity
	
	var wall_push = blackboard.get_value("current_wall_normal") * WALL_PUSH_FORCE
	actor.velocity = actor.velocity + (Vector3.UP * FORCE) + wall_push
	_grounded_timer.start()
	
	#get_parent().fire_event("on_start_falling")

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
		
	if Input.is_action_just_pressed("dive"):
		get_parent().fire_event("on_dive")
		return
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	if direction.is_zero_approx():
		actor.velocity = actor.velocity.move_toward(actor.velocity + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	else:
		actor.velocity = actor.velocity.move_toward(((direction * actor.get_entity_stats().get_agility()) * 0.8) + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	
	if actor.velocity.y < 0:
		get_parent().fire_event("on_start_falling")
		return
	
	if not _grounded_timer.is_stopped():
		return
	
	if actor.is_on_floor():
		get_parent().fire_event("on_landing")

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
