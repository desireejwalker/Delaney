@tool
extends FSMState

const ARIAL_ACTIONS_STRING: String = "arial_actions"

@export var gravity: float = 9.8
@export var acceleration: float = 40

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	_update_arial_actions(blackboard)

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var velocity = _handle_falling(actor.velocity, delta)
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_falling(current_velocity: Vector3, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(current_velocity + (Vector3.DOWN * gravity), acceleration * delta)
	return velocity

func _update_arial_actions(blackboard: Blackboard):
	if blackboard.get_value(ARIAL_ACTIONS_STRING) == null:
		blackboard.set_value(ARIAL_ACTIONS_STRING, [name])
		return
	blackboard.get_value(ARIAL_ACTIONS_STRING).append(name)
