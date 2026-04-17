@tool
extends FSMState

const IS_MOVING: String = "is_moving"
const ARIAL_ACTIONS_STRING: String = "arial_actions"

# Gameplay Parameters

@export var force: float = 15
@export var gravity: float = 9.8
@export var acceleration: float = 40
@export var speed: float = 10

@onready var grounded_timer: Timer = %GroundedTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	blackboard.set_value(IS_MOVING, true)
	_update_arial_actions(blackboard)
	
	var velocity = _handle_jump_force(actor.velocity)
	actor.mover.set_velocity(velocity)
	
	grounded_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var input_direction = actor.get_input_direction()
	var velocity = _handle_jumping(actor.velocity, input_direction, delta)

	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_jump_force(current_velocity: Vector3) -> Vector3:
	return current_velocity + (Vector3.UP * force)

func _handle_jumping(current_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * gravity), acceleration * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed) + (Vector3.DOWN * gravity), acceleration * delta)
	
	return velocity

func _update_arial_actions(blackboard: Blackboard):
	if blackboard.get_value(ARIAL_ACTIONS_STRING) == null:
		blackboard.set_value(ARIAL_ACTIONS_STRING, [name])
		return
	blackboard.get_value(ARIAL_ACTIONS_STRING).append(name)
