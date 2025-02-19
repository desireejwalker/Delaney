@tool
extends FSMState

# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", false)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("on_jump")
		return
	
	if (Input.is_action_pressed("move")):
		if (Input.is_action_pressed("run")):
			get_parent().fire_event("on_start_running")
			return
		
		get_parent().fire_event("on_start_walking")

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
