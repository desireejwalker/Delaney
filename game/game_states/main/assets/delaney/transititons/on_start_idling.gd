@tool
extends FSMTransition


# Executed when the transition is taken.
func _on_transition(_delta, _actor, _blackboard: Blackboard):
	pass


# Evaluates true, if the transition conditions are met.
func is_valid(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# changes what makes this transition valid depending on
	# the current state.
	if get_parent() is WalkState:
		# this transititon is valid if the player is not moving (or barely moving at all)
		return actor.linear_velocity.length() <= 1
	if get_parent() is LightAttackState:
		# this transititon is valid if the player is not moving (or barely moving at all)
		# and the light attack animation is not active
		# and the player is not holding the attack button
		return actor.linear_velocity.length() <= 1 and not blackboard.get_value("light_attack_animation_active") and not Input.is_action_pressed("attack")
	if get_parent() is LightRecoveryState:
		# this transition is valid if the player is not moving (or barely moving at all)
		# and the light recovery is inactive
		return actor.linear_velocity.length() <= 1 and not blackboard.get_value("light_recovery_active")
	if get_parent() is HeavyAttackState:
		# this transititon is valid if the player is not holding the attack button
		# and the the player is not moving (or barely moving at all)
		# and the launch level is 0
		return actor.linear_velocity.length() <= 1 and not Input.is_action_pressed("attack") and blackboard.get_value("launch_level") == 0
	if get_parent() is LaunchState:
		# this transition is valid if the launch level is -1
		# and the the player is not moving (or barely moving at all)
		return actor.linear_velocity.length() <= 1 and blackboard.get_value("launch_level") == -1
	if get_parent() is LaunchRecoveryState:
		# this transition is valid if the player is not moving (or barely moving at all)
		# and the launch recovery is inactive
		return actor.linear_velocity.length() <= 1 and not blackboard.get_value("launch_recovery_active")
	return false


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

