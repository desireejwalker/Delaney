@tool
extends FSMState

const IS_MOVING: String = "is_moving"
const ARIAL_ACTIONS_STRING: String = "arial_actions"

# Gameplay Parameters

@export var force: float = 30

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	_update_arial_actions(blackboard)
	
	blackboard.set_value(IS_MOVING, true)
	
	var velocity = _handle_ground_slam_force(actor.velocity)
	actor.mover.set_velocity(velocity)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_ground_slam_force(current_velocity: Vector3) -> Vector3:
	return current_velocity + (Vector3.DOWN * force)

func _update_arial_actions(blackboard: Blackboard):
	if blackboard.get_value(ARIAL_ACTIONS_STRING) == null:
		blackboard.set_value(ARIAL_ACTIONS_STRING, [name])
		return
	blackboard.get_value(ARIAL_ACTIONS_STRING).append(name)