@tool
extends BTLeaf

var last_target_position = Vector2.ZERO

# Gets called every tick of the behavior tree
func tick(_delta, actor, _blackboard: Blackboard) -> BTStatus:
	actor = actor as Monster
	
	# if delaney is in the player range AND we can see her, stop wandering and chase
	if actor.player:
		var collider = actor.line_of_sight_ray_cast_2d.get_collider() 
		if collider and collider == actor.player:
			print("found player while wandering")
			last_target_position = Vector2.ZERO
			return BTStatus.FAILURE
	
	if actor.navigation_agent_2d.is_navigation_finished() and actor.navigation_agent_2d.target_position != last_target_position:
		last_target_position = actor.navigation_agent_2d.target_position
		return BTStatus.SUCCESS
	
	if actor.navigation_agent_2d.target_position != last_target_position:
		return BTStatus.RUNNING
	
	# get random position in the wanderng range
	var position = Vector2(0, randf_range(0, actor.wander_range_collision_shape_2d.shape.radius)).rotated(randf_range(0, TAU)) + actor.wander_range_area_2d.global_position
	actor.move_to(position)
	
	return BTStatus.RUNNING


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

