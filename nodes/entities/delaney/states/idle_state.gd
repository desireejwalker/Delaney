@tool
class_name IdleState extends FSMState


# Executes after the state is entered.
func _on_enter(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# play idle animation based on actor.facing_direction
	match actor.facing_direction:
		Delaney.Direction.SOUTH:
			actor.animation_player.play("delaney_delta_idle_south")
		Delaney.Direction.SOUTH_EAST:
			actor.animation_player.play("delaney_delta_idle_south-east")
		Delaney.Direction.EAST:
			actor.animation_player.play("delaney_delta_idle_east")
		Delaney.Direction.NORTH_EAST:
			actor.animation_player.play("delaney_delta_idle_north-east")
		Delaney.Direction.NORTH:
			actor.animation_player.play("delaney_delta_idle_north")
		Delaney.Direction.NORTH_WEST:
			actor.animation_player.play("delaney_delta_idle_north-west")
		Delaney.Direction.WEST:
			actor.animation_player.play("delaney_delta_idle_west")
		Delaney.Direction.SOUTH_WEST:
			actor.animation_player.play("delaney_delta_idle_south-west")
	
	if actor.did_facing_change:
		actor.animation_player.seek(actor.last_facing_animation_position)


# Executes every _process call, if the state is active.
func _on_update(_delta, _actor, _blackboard: Blackboard):
	pass


# Executes before the state is exited.
func _on_exit(_actor, _blackboard: Blackboard):
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

