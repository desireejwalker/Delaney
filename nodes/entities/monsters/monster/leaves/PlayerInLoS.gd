@tool
extends BTLeaf


# Gets called every tick of the behavior tree
func tick(_delta, actor, _blackboard: Blackboard) -> BTStatus:
	var collided = actor.line_of_sight_ray_cast_2d.get_collider()
	if collided == null:
		return BTStatus.FAILURE
	
	if collided != actor.player:
		return BTStatus.FAILURE
	
	return BTStatus.SUCCESS

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

