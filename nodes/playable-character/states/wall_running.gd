@tool
extends FSMState

const ARIAL_ACTIONS_STRING: String = "arial_actions"

@export var wall_pull_force: float = 1.0
@export var gravity: float = 2.0
@export var acceleration: float = 40.0
@export var speed: float = 10.0
@export var vertical_stamina_max: float = 5.0
@export var vertical_speed: float = 6.5
@export var horizontal_speed_max: float = 2.2
@export var horizontal_speed_min: float = 1.5

var vertical_stamina = vertical_stamina_max

# Components
@onready var stamina_wheel: PlayableCharacterStaminaWheel = %PlayableCharacterStaminaWheel

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	_update_arial_actions(blackboard)
	
	vertical_stamina = vertical_stamina_max

	stamina_wheel.stamina_wheel.show_wheel()
	stamina_wheel.stamina_wheel.max_value = vertical_stamina_max

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var last_slide_collision = actor.get_last_slide_collision()
	var input_direction = actor.get_input_direction()
	
	var velocity = _handle_wallrunning(
		last_slide_collision.get_normal(),
		actor.velocity,
		input_direction,
		speed,
		-gravity,
		delta)
	
	# decrease vertical stamina while velocity is positive
	vertical_stamina = _handle_stamina(velocity.y, delta)
	stamina_wheel.stamina_wheel.current_value = vertical_stamina
	
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	stamina_wheel.stamina_wheel.hide_wheel()

func _handle_wallrunning(wall_normal: Vector3, current_velocity: Vector3, direction: Vector3, speed: float, gravity: float, delta) -> Vector3:
	var wall_pull = -wall_normal * wall_pull_force

	var dot = -wall_normal.dot(direction)
	var horizontal = remap(dot, 0, 1, horizontal_speed_max, horizontal_speed_min) * speed
	
	var vertical = gravity + dot * vertical_speed
	if vertical_stamina <= 0:
		dot = remap(dot, -1, 1, -1, 0)
		vertical = gravity + dot * vertical_speed
		
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

func _update_arial_actions(blackboard: Blackboard):
	if blackboard.get_value(ARIAL_ACTIONS_STRING) == null:
		blackboard.set_value(ARIAL_ACTIONS_STRING, [name])
		return
	blackboard.get_value(ARIAL_ACTIONS_STRING).append(name)