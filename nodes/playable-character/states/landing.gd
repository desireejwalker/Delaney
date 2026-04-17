@tool
extends FSMState

const ARIAL_ACTIONS_STRING: String = "arial_actions"

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("arial_actions", [])


# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
