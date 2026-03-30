@tool
extends FSMState

@export var wall_pull_force: float = 1.0
@export var gravity: float = 2.0
@export var acceleration: float = 40.0
@export var speed: float = 10.0
@export var vertical_stamina_max: float = 5.0
@export var vertical_speed: float = 6.5
@export var horizontal_speed_max: float = 2.2
@export var horizontal_speed_min: float = 1.5

var vertical_stamina = vertical_stamina_max

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	# if not last_slide_collision:
	# 	get_parent().fire_event("wallrunning/on_start_falling")
	# 	return
	
	# blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())
	
	vertical_stamina = vertical_stamina_max

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var last_slide_collision = actor.get_last_slide_collision()
	# if not last_slide_collision:
	# 	get_parent().fire_event("wallrunning/on_start_falling")
	# 	return
	
	# blackboard.set_value("current_wall_normal", last_slide_collision.get_normal())
	var input_direction = actor.get_input_direction()
	
	var velocity = _handle_wallrunning(
		-last_slide_collision.get_normal(),
		actor.velocity,
		input_direction,
		speed,
		-gravity,
		delta)
	
	# decrease vertical stamina while velocity is positive
	vertical_stamina = _handle_stamina(velocity.y, delta)
	print(vertical_stamina)
	
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_wallrunning(wall_negative_normal: Vector3, current_velocity: Vector3, direction: Vector3, speed: float, gravity: float, delta) -> Vector3:
	var wall_pull = wall_negative_normal * wall_pull_force
	var dot = wall_negative_normal.dot(direction)
	var horizontal = remap(dot, 0, 1, horizontal_speed_max, horizontal_speed_min) * speed
	
	var vertical = gravity + dot * vertical_speed
	if vertical_stamina <= 0:
		dot = remap(dot, -1, 1, -1, 0)
		vertical = gravity + dot * vertical_speed
	# print(vertical)
		
	var target_velocity = Vector3(
		float(direction.x * horizontal),
		vertical,
		float(direction.z * horizontal))
	
	return current_velocity.move_toward(target_velocity, acceleration * delta) + wall_pull

func _handle_stamina(velocity_y: float, delta: float):
	var stamina = vertical_stamina
	if velocity_y > 0:
		stamina = stamina - (velocity_y * delta)
	
	return stamina
