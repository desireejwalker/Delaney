@tool
extends FSMState

var animation_finished := false

# Executes after the state is entered.
func _on_enter(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	animation_finished = false
	_handle_attack(actor)
	_handle_animation(actor)


# Executes every _process call, if the state is active.
func _on_update(_delta, _actor, _blackboard: Blackboard):
	pass


# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# disconnect _on_animation_player_animation_finished
	actor.animation_player.animation_finished.disconnect(_on_animation_player_animation_finished)


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_attack(actor: Delaney):
	# if the weapon equipped allows for auto-targeting
	# face player in the direction of the mouse
	var attack_direction = actor.facing_vector
	if actor.auto_target_light_attack:
		attack_direction = actor.mouse_direction
		actor.angle_radians = atan2(attack_direction.y, attack_direction.x)
		actor.angle_degrees = rad_to_deg(actor.angle_radians)
	
	# give em a little push
	actor.apply_central_impulse(attack_direction * 40)

func _handle_animation(actor: Delaney):
	# connect _on_animation_player_animation_finished
	actor.animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	# play idle animation based on actor.facing_direction
	match actor.facing_direction:
		Delaney.Direction.SOUTH:
			actor.animation_player.play("player_light_attack_south")
		Delaney.Direction.SOUTH_EAST:
			actor.animation_player.play("player_light_attack_southeast")
		Delaney.Direction.EAST:
			actor.animation_player.play("player_light_attack_east")
		Delaney.Direction.NORTH_EAST:
			actor.animation_player.play("player_light_attack_northeast")
		Delaney.Direction.NORTH:
			actor.animation_player.play("player_light_attack_north")
		Delaney.Direction.NORTH_WEST:
			actor.animation_player.play("player_light_attack_northwest")
		Delaney.Direction.WEST:
			actor.animation_player.play("player_light_attack_west")
		Delaney.Direction.SOUTH_WEST:
			actor.animation_player.play("player_light_attack_southwest")

func _on_animation_player_animation_finished(_anim_name):
		animation_finished = true
