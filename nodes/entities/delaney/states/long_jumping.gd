@tool
extends FSMState

const HORIZONTAL_FORCE: float = 20.0
const VERTICAL_FORCE: float = 7.5
const GRAVITY: float = 9.8
const ACCELERATION: int = 40
const MAX_HORIZONTAL_VELOCITY: float = 20.0

@onready var _grounded_timer: Timer = %GroundedTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)
	
	actor = actor as DelaneyEntity
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	if direction.is_zero_approx():
		direction = actor.velocity.normalized()
	
	var horizontal_velocity = Vector3(direction.x, 0.0, direction.z) * HORIZONTAL_FORCE
	horizontal_velocity = horizontal_velocity.limit_length(MAX_HORIZONTAL_VELOCITY)
	var vertical_velocity = Vector3.UP * VERTICAL_FORCE
	
	actor.velocity = horizontal_velocity + vertical_velocity
	#var horizontal_velocity = Vector3(actor.velocity.x, 0, actor.velocity.z)
	var horizontal_velocity_normalized = horizontal_velocity.normalized()
	if not horizontal_velocity.is_zero_approx():
		actor.rotation.y = atan2(horizontal_velocity_normalized.x, horizontal_velocity_normalized.z)
	
	_grounded_timer.start()
	
	#get_parent().fire_event("on_start_falling")

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if Input.is_action_just_pressed("dive"):
		get_parent().fire_event("long_jumping/on_dive")
		return
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	var horizontal_velocity = (direction * actor.get_entity_stats().get_agility()) * 0.6
	if direction.is_zero_approx():
		horizontal_velocity = actor.velocity.normalized() * 0.6
	
	actor.velocity = actor.velocity.move_toward(horizontal_velocity + (Vector3.DOWN * GRAVITY), ACCELERATION * delta)
	
	if actor.velocity.y < 0:
		get_parent().fire_event("long_jumping/on_start_falling")
		return
	
	if not _grounded_timer.is_stopped():
		return
	
	if actor.is_on_floor():
		get_parent().fire_event("long_jumping/on_landing")


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
