@tool
extends FSMState

@export var wall_push_force: float = 14
@export var force: float = 12.5
@export var gravity: float = 9.8
@export var acceleration: float = 40
@export var speed: float = 10

@onready var grounded_timer: Timer = %GroundedTimer

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	var last_slide_collision = actor.get_last_slide_collision()
	
	var velocity = _handle_wall_jump_force(actor.velocity, last_slide_collision.get_normal())
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())
	
	grounded_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var input_direction = actor.get_input_direction()
	var velocity = _handle_wall_jump(
		actor.velocity,
		input_direction,
		speed,
		delta)
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_wall_jump_force(current_velocity: Vector3, current_wall_normal: Vector3) -> Vector3:
	var wall_push = current_wall_normal * wall_push_force
	var velocity = current_velocity + (Vector3.UP * force) + wall_push
	
	return velocity

func _handle_wall_jump(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * gravity), acceleration * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed) + (Vector3.DOWN * gravity), acceleration * delta)
	
	return velocity