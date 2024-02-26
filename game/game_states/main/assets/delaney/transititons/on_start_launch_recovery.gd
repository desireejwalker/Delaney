@tool
extends FSMTransition


# Executed when the transition is taken.
func _on_transition(_delta, _actor, _blackboard: Blackboard):
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(_actor, blackboard: Blackboard):
	# this transition is valid if delaney is in a launch
	# and the recovery button is pressed
	return blackboard.get_value("launch_level") > 0 and Input.is_action_pressed("recovery")


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

