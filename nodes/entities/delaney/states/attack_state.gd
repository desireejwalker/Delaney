@tool
class_name AttackState extends FSMState

const LAUNCH_ARROW = preload("res://game/game_states/main/assets/ui/launch_arrow/launch_arrow.tscn")

# combo entries
const SWING_360_DEGREES = preload("res://game/resources/combo_action_entries/swing/swing_360-degrees.tres")
const SWING_720_DEGREES = preload("res://game/resources/combo_action_entries/swing/swing_720-degrees.tres")
const SWING_1080_DEGREES = preload("res://game/resources/combo_action_entries/swing/swing_1080-degrees.tres")

var given_combo_entries = {
	SWING_360_DEGREES: false,
	SWING_720_DEGREES: false,
	SWING_1080_DEGREES: false
}

@onready var heavy_attack_timer := $HeavyAttackStateTimer

var launch_arrow_instance: Node2D

var next_launch_level := 0
var heavy_attack_speed: float

var elapsed_angle: float = 0

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	blackboard.set_value("launch_level", 0)
	
	if actor.hammer_type.use_auto_aim:
		actor.set_angle_radians(atan2(actor.mouse_direction.y, actor.mouse_direction.x))
	
	heavy_attack_speed = actor.DEFAULT_HEAVY_ATTACK_SPEED
	
	actor.angle_degrees -= 45
	elapsed_angle = 0
	given_combo_entries = {
		SWING_360_DEGREES: false,
		SWING_720_DEGREES: false,
		SWING_1080_DEGREES: false
	}
	
	actor.light_dust.emitting = true
	
	# set next_launch_level to 1 so that we know to advance to launch level 1
	# next time the heavy_attack_timer fires the timeout signal
	next_launch_level = 1
	# start the heavy_attack_timer at 1.0 to wait that amount of seconds
	# before advancing to launch_level 1
	heavy_attack_timer.start(1.0)


# Executes every _process call, if the state is active.
func _on_update(delta, actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# handle advancing to higher launch levels (up to 3)
	match next_launch_level:
		1:
			if heavy_attack_timer.time_left == 0:
				blackboard.set_value("launch_level", next_launch_level)
				next_launch_level += 1
				
				# instantiate the particle system for this level
				actor.add_child(actor.LAUNCH_LEVEL_PARTICLE_SCENES[0].instantiate())
				
				# instantiate the launch arrow to help the player see what direction they're about to fling themselves in
				launch_arrow_instance = LAUNCH_ARROW.instantiate()
				actor.add_child(launch_arrow_instance)
				
				# increase the heavy_attack_speed to make delaney spin faster
				heavy_attack_speed = actor.DEFAULT_HEAVY_ATTACK_SPEED * 2

				# start the heavy_attack_timer at 1.5 to wait that amount of seconds
				# before advancing to launch_level 2
				heavy_attack_timer.start(1.5)
		2:
			if heavy_attack_timer.time_left == 0:
				blackboard.set_value("launch_level", next_launch_level)
				next_launch_level += 1
				
				# instantiate the particle system for this level
				actor.add_child(actor.LAUNCH_LEVEL_PARTICLE_SCENES[1].instantiate())
				
				# increase the heavy_attack_speed to make delaney spin faster
				heavy_attack_speed = actor.DEFAULT_HEAVY_ATTACK_SPEED * 3
				
				# start the heavy_attack_timer at 2.0 to wait that amount of seconds
				# before advancing to launch_level 3
				heavy_attack_timer.start(2)
		3:
			if heavy_attack_timer.time_left == 0:
				blackboard.set_value("launch_level", next_launch_level)
				# just set next launch level to 4 to keep from hitting this case over
				# and over again
				next_launch_level += 1
				
				# instantiate the particle system for this level
				actor.add_child(actor.LAUNCH_LEVEL_PARTICLE_SCENES[2].instantiate())
				
				# increase the heavy_attack_speed to make delaney spin faster
				heavy_attack_speed = actor.DEFAULT_HEAVY_ATTACK_SPEED * 4
	
	# constantly add to delaney's facing angle to make her spin
	_handle_spin(delta, actor)
	_handle_animation(actor)
	
	# move delaney slowly towards the mouse
	_handle_movement(actor)


# Executes before the state is exited.
func _on_exit(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	actor.light_dust.emitting = false
	
	if launch_arrow_instance != null:
		launch_arrow_instance.launch()
	
	# if never advanced to the launch level 1, set launch level to -1
	# to signify no launch
	if blackboard.get_value("launch_level") == 0:
		blackboard.set_value("launch_level", -1)


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_spin(delta: float, actor: Delaney):
	actor.set_angle_degrees(actor.angle_degrees + (heavy_attack_speed * delta))
	elapsed_angle += (heavy_attack_speed * delta)
	_handle_spin_combo_entry(actor)

func _handle_movement(actor: Delaney):
	# apply velocity to delaney
	actor.velocity = actor.mouse_direction * (actor.DEFAULT_SPEED * 0.2)
	actor.move_and_slide()

func _handle_animation(actor: Delaney):
	# play walking animation based on actor.facing_direction
	match actor.facing_direction:
		Delaney.Direction.SOUTH:
			actor.animation_player.play("delaney_delta_attack_south")
		Delaney.Direction.SOUTH_EAST:
			actor.animation_player.play("delaney_delta_attack_south-east")
		Delaney.Direction.EAST:
			actor.animation_player.play("delaney_delta_attack_east")
		Delaney.Direction.NORTH_EAST:
			actor.animation_player.play("delaney_delta_attack_north-east")
		Delaney.Direction.NORTH:
			actor.animation_player.play("delaney_delta_attack_north")
		Delaney.Direction.NORTH_WEST:
			actor.animation_player.play("delaney_delta_attack_north-west")
		Delaney.Direction.WEST:
			actor.animation_player.play("delaney_delta_attack_west")
		Delaney.Direction.SOUTH_WEST:
			actor.animation_player.play("delaney_delta_attack_south-west")

func _handle_spin_combo_entry(actor: Delaney):
	if elapsed_angle > 1080:
		if not given_combo_entries[SWING_1080_DEGREES]:
			actor._did_combo_action(SWING_1080_DEGREES)
			given_combo_entries[SWING_1080_DEGREES] = true
	elif elapsed_angle > 720:
		if not given_combo_entries[SWING_720_DEGREES]:
			actor._did_combo_action(SWING_720_DEGREES)
			given_combo_entries[SWING_720_DEGREES] = true
	elif elapsed_angle > 360:
		if not given_combo_entries[SWING_360_DEGREES]:
			actor._did_combo_action(SWING_360_DEGREES)
			given_combo_entries[SWING_360_DEGREES] = true
