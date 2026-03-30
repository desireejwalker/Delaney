@tool
extends FSMState

const IS_MOVING: String = "is_moving"

# Gameplay Parameters

@export var force: float = 30

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
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