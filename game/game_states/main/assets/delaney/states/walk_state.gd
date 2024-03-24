@tool
class_name WalkState extends FSMState

@onready var footstep_audio_stream_player_2d = $FootstepAudioStreamPlayer2D

var _on_footstep_event_handler

var _universal_walk_animation_position: float = 0

# Executes after the state is entered.
func _on_enter(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	_on_footstep_event_handler = func(terrain_type): _on_footstep(actor, terrain_type)
	actor.on_footstep.connect(_on_footstep_event_handler)

# Executes every _process call, if the state is active.
func _on_update(delta, actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	_handle_rotation(actor)
	_handle_movement(actor)
	_handle_animation(actor)

# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	actor.on_footstep.disconnect(_on_footstep_event_handler)

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_rotation(actor: Delaney):
	# dont reset the angle to 0 if movement direction is Vector2.ZERO
	if actor.movement_direction.is_zero_approx():
		return
	
	# set facing angle based on input direct
	actor.set_angle_radians(atan2(actor.movement_direction.y, actor.movement_direction.x))

func _handle_movement(actor: Delaney):
	# apply velocity to delaney
	actor.velocity = actor.movement_direction * actor.DEFAULT_SPEED
	actor.move_and_slide()
	
	actor.animation_player.set_speed_scale((actor.velocity.length() / 120) + 1)

func _handle_animation(actor: Delaney):
	# update the universal walk animation position to keep walk animations seemless when
	# switching directions
	_universal_walk_animation_position = actor.animation_player.current_animation_position
	
	# play walking animation based on actor.facing_direction
	match actor.facing_direction:
		Delaney.Direction.SOUTH:
			actor.animation_player.play("delaney_delta_run_south")
		Delaney.Direction.SOUTH_EAST:
			actor.animation_player.play("delaney_delta_run_south-east")
		Delaney.Direction.EAST:
			actor.animation_player.play("delaney_delta_run_east")
		Delaney.Direction.NORTH_EAST:
			actor.animation_player.play("delaney_delta_run_north-east")
		Delaney.Direction.NORTH:
			actor.animation_player.play("delaney_delta_run_north")
		Delaney.Direction.NORTH_WEST:
			actor.animation_player.play("delaney_delta_run_north-west")
		Delaney.Direction.WEST:
			actor.animation_player.play("delaney_delta_run_west")
		Delaney.Direction.SOUTH_WEST:
			actor.animation_player.play("delaney_delta_run_south-west")
	
	# if the direction was changed in this frame, make sure to seek to the
	# universal walk animation position to keep walk animations seemless
	if actor.did_facing_change:
		actor.animation_player.seek(_universal_walk_animation_position)

func _on_footstep(actor: Delaney, terrain_type: int):
	# create particle effects
	var light_footstep := actor.LIGHT_FOOTSTEP_SCENE.instantiate()
	actor.add_child(light_footstep)
	light_footstep.position += Vector2(0, 20)
	
	# play random footstep sound according to the terrain type underfoot
	footstep_audio_stream_player_2d.stream = actor.FOOTSTEP_SOUNDS[terrain_type][randi_range(0, 2)]
	footstep_audio_stream_player_2d.play()
