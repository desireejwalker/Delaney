@tool
class_name LightRecoveryState extends FSMState

@onready var light_recovery_timer := $LightRecoveryStateTimer

var _on_light_recovery_timer_finished_event_handler
var _on_footstep_event_handler

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# push the player in the direction of their input
	# basically instantly redirecting them
	actor.apply_central_impulse(actor.movement_direction * 200)
	
	actor.light_dust.emitting = true
	
	blackboard.set_value("light_recovery_active", true)
	
	_on_light_recovery_timer_finished_event_handler = func(): blackboard.set_value("light_recovery_active", false)
	light_recovery_timer.timeout.connect(_on_light_recovery_timer_finished_event_handler)
	
	_on_footstep_event_handler = func(terrain_type): _on_footstep(actor, terrain_type)
	actor.on_footstep.connect(_on_footstep_event_handler)
	
	# the recovery only lasts for 1.0s so start the timer
	light_recovery_timer.start(1.0)


# Executes every _process call, if the state is active.
func _on_update(_delta, actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	_handle_movement(actor)
	_handle_animation(actor)


# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	actor.light_dust.emitting = false
	
	light_recovery_timer.timeout.disconnect(_on_light_recovery_timer_finished_event_handler)
	actor.on_footstep.disconnect(_on_footstep_event_handler)


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_movement(actor: Delaney):
	actor.linear_damp = actor.DEFAULT_DAMPING
	
	# apply forces in movement direction
	actor.apply_central_force(actor.movement_direction * actor.DEFAULT_SPEED * 1.6)

	# set facing angle based on velocity
	actor.set_angle_radians(atan2(actor.linear_velocity.y, actor.linear_velocity.x))
	
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

func _on_footstep(actor: Delaney, terrain_type: int):
	# create particle effects
	var light_footstep := actor.LIGHT_FOOTSTEP_SCENE.instantiate()
	actor.add_child(light_footstep)
	light_footstep.position += Vector2(0, 20)
	
	# play random footstep sound according to the terrain type underfoot
	actor.footstep_audio_stream_player_2d.stream = actor.FOOTSTEP_SOUNDS[terrain_type][randi_range(0, 2)]
	actor.footstep_audio_stream_player_2d.play()
