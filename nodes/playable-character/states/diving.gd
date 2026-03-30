@tool
extends FSMState

@export var horizontal_force: float = 20.0
@export var vertical_force: float = 7.5
@export var gravity: float = 9.8
@export var acceleration: float = 40
@export var speed: float = 10
@export var max_horizontal_velocity: float = 20.0

@onready var _grounded_timer: Timer = %GroundedTimer

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var input_direction = actor.get_input_direction()
	if input_direction.is_zero_approx():
		input_direction = actor.velocity.normalized()
	var velocity = _handle_long_jump_force(input_direction)
	
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())
	
	_grounded_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var input_direction = actor.get_input_direction()
	var velocity = _handle_long_jumping(actor.velocity, input_direction, delta)

	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_long_jump_force(direction: Vector3) -> Vector3:
	var horizontal_velocity = Vector3(
		direction.x * horizontal_force,
		0,
		direction.z * horizontal_force).limit_length(max_horizontal_velocity)
	var vertical_velocity = Vector3.UP * vertical_force
	var velocity = horizontal_velocity + vertical_velocity
	return velocity

func _handle_long_jumping(current_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	var horizontal_velocity = direction * speed
	if direction.is_zero_approx():
		horizontal_velocity = current_velocity.normalized() * speed
	var velocity = current_velocity.move_toward(horizontal_velocity + (Vector3.DOWN * gravity), acceleration * delta)
	return velocity
