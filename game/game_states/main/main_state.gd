@tool
extends FSMState

const PLAYER = preload("res://game/game_states/main/assets/player/player.tscn")
var player_instance: Player

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	# instantiate the player and add it to the GameManager as a child
	# only if the game wasn't paused
	if blackboard.get_value("is_paused"):
		return
	
	player_instance = PLAYER.instantiate()
	# set the player's position to be in the middle of the CurrentFloor's StartingRoom
	# multiplied by 16 to account for pixels per unit
	var player_start_position = actor.floor_manager.CurrentFloor.FloorGenerationOutput.StartingRoom.position * 16
	player_instance.position = player_start_position
	actor.add_child(player_instance)
	
	
	# make sure the blackboard says that the game isn't paused
	blackboard.set_value("is_paused", false)


# Executes every _process call, if the state is active.
func _on_update(_delta, actor, blackboard: Blackboard):
	# if the menu button was just pressed, pause
	if Input.is_action_just_pressed("menu"):
		actor.game_state_machine.fire_event("on_paused")
		
		# set is_paused on the blackboard to true to keep from
		# freeing the player when pausing
		blackboard.set_value("is_paused", true)


# Executes before the state is exited.
func _on_exit(actor, blackboard: Blackboard):
	
	# free the player if the game wasn't paused
	if blackboard.get_value("is_paused"):
		return
	
	actor.remove_child(player_instance)
	player_instance.queue_free()


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

