@tool
extends FSMTransition


# Executed when the transition is taken.
func _on_transition(_delta, _actor, _blackboard: Blackboard):
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(_actor, blackboard: Blackboard):
	# valid only if recovery button is pressed and the light attack animation is active
	return Input.is_action_pressed("recovery") and blackboard.get_value("light_attack_animation_active")


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

