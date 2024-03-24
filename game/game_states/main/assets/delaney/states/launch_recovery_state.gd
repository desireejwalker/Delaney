@tool
class_name LaunchRecoveryState extends FSMState

const DEFAULT_RECOVERY_SPEED: float = 300

@onready var launch_recovery_timer := $LaunchRecoveryStateTimer
@onready var launch_timer := $"../LaunchState/LaunchStateTimer"
@onready var launch_recovery_state_animation_player = $LaunchRecoveryStateAnimationPlayer

@onready var footstep_audio_stream_player_2d = $FootstepAudioStreamPlayer2D

var _on_launch_recovery_timer_finished_event_handler
var _on_footstep_event_handler

var recovery_speed: float
var _universal_walk_animation_position: float = 0

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# stop the launch_timer
	launch_timer.stop()
	
	# stop the trail particle systems from emitting
	actor.launch_level_1_trail.emitting = false
	actor.launch_level_2_trail.emitting = false
	actor.launch_level_3_trail.emitting = false
	
	# instantiate the burst for the launch level that was stopped
	match blackboard.get_value("launch_level"):
		1:
			actor.add_child(actor.LAUNCH_LEVEL_PARTICLE_SCENES[0].instantiate())
		2:
			actor.add_child(actor.LAUNCH_LEVEL_PARTICLE_SCENES[1].instantiate())
		3:
			actor.add_child(actor.LAUNCH_LEVEL_PARTICLE_SCENES[2].instantiate())
	
	# -1 signifies that a launch is over
	# 0 signifies that the player is using their heavy attack
	blackboard.set_value("launch_level", -1)
	
	# give em some extra velocity
	actor.velocity = actor.movement_direction * recovery_speed
	actor.animation_player.speed_scale = 3
	
	# make sure the blackboard knows that the launch recovery timer
	# is active and ticking
	blackboard.set_value("launch_recovery_active", true)
	
	_on_launch_recovery_timer_finished_event_handler = func(): blackboard.set_value("launch_recovery_active", false)
	launch_recovery_timer.timeout.connect(_on_launch_recovery_timer_finished_event_handler)
	
	_on_footstep_event_handler = func(terrain_type): _on_footstep(actor, terrain_type)
	actor.on_footstep.connect(_on_footstep_event_handler)
	
	# the recovery only lasts for 1.0s so start the timer
	launch_recovery_timer.start(1.0)
	launch_recovery_state_animation_player.play("default")


# Executes every _process call, if the state is active.
func _on_update(delta, actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	_handle_movement(delta, actor)
	_handle_animation(actor)


# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	actor.animation_player.speed_scale = 1
	
	launch_recovery_timer.timeout.disconnect(_on_launch_recovery_timer_finished_event_handler)
	actor.on_footstep.disconnect(_on_footstep_event_handler)


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_movement(delta: float, actor: Delaney):
	# decay recovery speed to 100
	if not actor.movement_direction.is_zero_approx():
		actor.velocity = actor.movement_direction * recovery_speed
	actor.move_and_slide()

	# set facing angle based on velocity
	actor.set_angle_radians(atan2(actor.velocity.y, actor.velocity.x))

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
			actor.animation_player.play("delaney_delta_runk_north-west")
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
