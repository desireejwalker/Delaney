@tool
extends FSMState


# Executes after the state is entered.
func _on_enter(_actor, _blackboard: Blackboard):
	pass


# Executes every _process call, if the state is active.
func _on_update(delta, actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	_handle_movement(actor)
	_handle_animation(actor)


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

func _handle_movement(actor: Delaney):
	actor.linear_damp = actor.DEFAULT_DAMPING
	
	# check if the linear_velocity is small enough to just set to zero
	# NOTE: there is likely a better way to do this... search later.
	#if linear_velocity.length() <= 1:
		#movement = "idle"
	#else:	
		#movement = "walk"
	
	# apply forces in movement direction
	actor.apply_central_force(actor.movement_direction * actor.DEFAULT_SPEED)

	# set facing angle based on velocity
	actor.angle_radians = atan2(actor.linear_velocity.y, actor.linear_velocity.x)
	actor.angle_degrees = rad_to_deg(actor.angle_radians)
	
	# adjust animation speed to look consistent with speed
	actor.animation_player.set_speed_scale((actor.linear_velocity.length() / 200) + 1)

func _handle_animation(actor: Delaney):
	# play walking animation based on actor.facing_direction
	match actor.facing_direction:
		Delaney.Direction.SOUTH:
			actor.animation_player.play("player_walk_south")
		Delaney.Direction.SOUTH_EAST:
			actor.animation_player.play("player_walk_southeast")
		Delaney.Direction.EAST:
			actor.animation_player.play("player_walk_east")
		Delaney.Direction.NORTH_EAST:
			actor.animation_player.play("player_walk_northeast")
		Delaney.Direction.NORTH:
			actor.animation_player.play("player_walk_north")
		Delaney.Direction.NORTH_WEST:
			actor.animation_player.play("player_walk_northwest")
		Delaney.Direction.WEST:
			actor.animation_player.play("player_walk_west")
		Delaney.Direction.SOUTH_WEST:
			actor.animation_player.play("player_walk_southwest")
