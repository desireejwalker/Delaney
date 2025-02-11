@tool
class_name MonsterGenerationState extends FSMState


# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as GameManager
	
	var floor = actor.floor_manager.CurrentFloor
	var floor_generation_output = floor.FloorGenerationOutput


# Executes every _process call, if the state is active.
func _on_update(_delta, _actor, _blackboard: Blackboard):
	pass


# Executes before the state is exited.
func _on_exit(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as GameManager
	
	# free the loading screen
	actor.remove_child(blackboard.get_value("loading_screen_instance"))
	blackboard.get_value("loading_screen_instance").queue_free()


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

