class_name LightAttack extends FSMState

var clockwise: bool
var target_angle_degrees: float
var speed: float = 600

func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	# cast actor
	actor = actor as Delaney
	
	if actor.hammer_type.use_auto_aim:
		if clockwise:
			actor.set_angle_degrees(rad_to_deg(atan2(actor.mouse_direction.y, actor.mouse_direction.x)) - 90)
		else:
			actor.set_angle_degrees(rad_to_deg(atan2(actor.mouse_direction.y, actor.mouse_direction.x)) + 90)
	else:
		if clockwise:
			actor.set_angle_degrees(actor.angle_degrees - 90)
		else:
			actor.set_angle_degrees(actor.angle_degrees + 90)
	
	if clockwise:
		target_angle_degrees = actor.angle_degrees + 180
	else:
		target_angle_degrees = actor.angle_degrees - 180

## Executes every process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	# cast actor
	actor = actor as Delaney
	
	if clockwise:
		if actor.angle_degrees > target_angle_degrees:
			actor.control_fsm.fire_event("end_attack")
		
		actor.set_angle_degrees(actor.angle_degrees + (speed * delta))
	else:
		if actor.angle_degrees < target_angle_degrees:
			actor.control_fsm.fire_event("end_attack")
		
		actor.set_angle_degrees(actor.angle_degrees - (speed * delta))
	
	_handle_animation(actor)

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

## Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass
