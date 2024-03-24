@tool
class_name LaunchState extends FSMState

@onready var launch_timer := $LaunchStateTimer

var _on_end_launch_event_handler

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# give delaney her launch velocity
	actor.velocity = actor.mouse_direction * 600
	
	# hide sprites
	actor.delaney_sprite.visible = false
	actor.hammer.visible = false
	
	match blackboard.get_value("launch_level"):
		1:
			actor.launch_level_1_trail.emitting = true
			_on_end_launch_event_handler = func(): _on_launch_end(actor, blackboard)
			launch_timer.timeout.connect(_on_end_launch_event_handler)
			launch_timer.start(1.0)
		2:
			actor.launch_level_2_trail.emitting = true
			_on_end_launch_event_handler = func(): _on_launch_end(actor, blackboard)
			launch_timer.timeout.connect(_on_end_launch_event_handler)
			launch_timer.start(2.0)
		3:
			actor.launch_level_3_trail.emitting = true
			_on_end_launch_event_handler = func(): _on_launch_end(actor, blackboard)
			launch_timer.timeout.connect(_on_end_launch_event_handler)
			launch_timer.start(3.0)


# Executes every _process call, if the state is active.
func _on_update(_delta, actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# move delaney along her velocity vector until collision,
	# depending on where the collsion was, invert velocity
	var did_collide = actor.move_and_slide()
	if did_collide:
		_handle_ricochet(actor)
	
	# set facing angle based on velocity
	actor.set_angle_radians(atan2(actor.velocity.y, actor.velocity.x))


# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	# cast actor
	actor = actor as Delaney
	
	# disconnect the timeout signal 
	launch_timer.timeout.disconnect(_on_end_launch_event_handler)
	
	# show sprites and return player physics values to normal
	actor.delaney_sprite.visible = true
	actor.hammer.visible = true


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_ricochet(actor: Delaney):
	var collision = actor.get_last_slide_collision()
	var collision_normal = collision.get_normal()
	
	# since there are no irregular walls (at least not yet @_@)
	# just check the four cardinal directions and invert velocity
	# accordingly
	if (collision_normal == Vector2.DOWN or collision_normal == Vector2.UP):
		actor.velocity = Vector2(actor.velocity.x, -actor.velocity.y)
	elif (collision_normal == Vector2.RIGHT or collision_normal == Vector2.LEFT):
		actor.velocity = Vector2(-actor.velocity.x, actor.velocity.y)
	print(actor.velocity)

func _on_launch_end(actor: Delaney, blackboard: Blackboard):
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
