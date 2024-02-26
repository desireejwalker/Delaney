@tool
class_name HeavyAttackState extends FSMState

@onready var heavy_attack_timer := $HeavyAttackStateTimer

var next_launch_level := 0
var heavy_attack_speed: float

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	blackboard.set_value("launch_level", 0)
	
	heavy_attack_speed = actor.DEFAULT_HEAVY_ATTACK_SPEED
	# add 45 to the facing angle make the transition from light to heavy smoother
	actor.angle_degrees += 45
	
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

func _handle_movement(actor: Delaney):
	actor.linear_damp = actor.DEFAULT_DAMPING * 0.5
	
	# apply forces in movement direction
	actor.apply_central_force(actor.mouse_direction * (actor.DEFAULT_SPEED * 0.2))

func _handle_animation(actor: Delaney):
	# play walking animation based on actor.facing_direction
	match actor.facing_direction:
		Delaney.Direction.SOUTH:
			actor.animation_player.play("player_heavy_attack_south")
		Delaney.Direction.SOUTH_EAST:
			actor.animation_player.play("player_heavy_attack_southeast")
		Delaney.Direction.EAST:
			actor.animation_player.play("player_heavy_attack_east")
		Delaney.Direction.NORTH_EAST:
			actor.animation_player.play("player_heavy_attack_northeast")
		Delaney.Direction.NORTH:
			actor.animation_player.play("player_heavy_attack_north")
		Delaney.Direction.NORTH_WEST:
			actor.animation_player.play("player_heavy_attack_northwest")
		Delaney.Direction.WEST:
			actor.animation_player.play("player_heavy_attack_west")
		Delaney.Direction.SOUTH_WEST:
			actor.animation_player.play("player_heavy_attack_southwest")
