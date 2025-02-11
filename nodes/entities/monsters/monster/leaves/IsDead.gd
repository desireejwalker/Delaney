@tool
extends BTLeaf


# Gets called every tick of the behavior tree
func tick(_delta, actor, _blackboard: Blackboard) -> BTStatus:
	actor = actor as Monster
	
	if actor.is_dead:
		return BTStatus.SUCCESS
	return BTStatus.FAILURE

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

