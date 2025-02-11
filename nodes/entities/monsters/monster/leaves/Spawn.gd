@tool
extends BTLeaf

var spawn_animation_finished: bool = false

# Gets called every tick of the behavior tree
func tick(_delta, actor, _blackboard: Blackboard) -> BTStatus:
	actor = actor as Monster
	
	if not actor.animation_player.animation_finished.is_connected(_on_spawn_animation_finished):
		actor.animation_player.animation_finished.connect(_on_spawn_animation_finished)
	
	if spawn_animation_finished:
		actor.is_spawned = true
		spawn_animation_finished = false
		actor.animation_player.animation_finished.disconnect(_on_spawn_animation_finished)
		print("spawned")
		return BTStatus.SUCCESS
	
	actor.animation_player.play("spawn")
	return BTStatus.RUNNING

func _on_spawn_animation_finished(_anim_name: String):
	spawn_animation_finished = true


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

