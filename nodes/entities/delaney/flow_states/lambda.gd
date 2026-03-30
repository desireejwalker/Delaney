@tool
extends FSMState

@export var launch_parameters: LaunchParameters

signal on_update(delta: float, actor: Node, blackboard: Blackboard)

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: Blackboard) -> void:
	pass

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	on_update.emit(delta, actor, blackboard)

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
