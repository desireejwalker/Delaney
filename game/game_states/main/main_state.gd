@tool
extends FSMState

const PAUSE_SCENE = preload("res://game/game_states/main/assets/pause/pause_scene.tscn")
var pause_instance: CanvasLayer
const MAIN_UI_SCENE = preload("res://game/game_states/main/assets/ui/main_ui.tscn")
var main_ui_instance: MainUI
const PLAYER = preload("res://game/game_states/main/assets/player/player.tscn")
var player_instance: Player

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	player_instance = PLAYER.instantiate()
	# set the player's position to be in the middle of the CurrentFloor's StartingRoom
	# multiplied by 16 to account for pixels per unit
	var player_start_position = actor.floor_manager.CurrentFloor.FloorGenerationOutput.StartingRoom.position * 16
	player_instance.position = player_start_position
	actor.add_child(player_instance)
	
	# instantiate the main ui scene
	main_ui_instance = MAIN_UI_SCENE.instantiate()
	actor.add_child(main_ui_instance)
	
	# set the marker tilemap of the minimap
	main_ui_instance.set_marker_tilemap(actor.floor_manager.CurrentFloor.GetMarkerTileMap())
	
	# initialize paused to false
	_handle_pause(false, actor, blackboard)


# Executes every _process call, if the state is active.
func _on_update(_delta, actor, blackboard: Blackboard):
	# update the rotation and position of the player marker on the main ui
	main_ui_instance.set_player_marker_rotation(player_instance.angle_radians)
	main_ui_instance.set_player_marker_position(player_instance.position)
	
	# if the menu button was just pressed, toggle paused
	if Input.is_action_just_pressed("menu"):
		_handle_pause(not blackboard.get_value("paused"), actor, blackboard)
	
	# if paused and the quit button was just pressed, fire the on_paused_and_quitted event
	# to clear the floor and return to the title state.
	if blackboard.get_value("paused") and Input.is_action_just_pressed("quit"):
		# unpause just to be safe
		_handle_pause(false, actor, blackboard)
		actor.game_state_machine.fire_event("on_paused_and_quitted")

# Executes before the state is exited.
func _on_exit(actor, blackboard: Blackboard):
	# remove and free the main ui scene
	actor.remove_child(main_ui_instance)
	main_ui_instance.queue_free()
	
	# remove and free the player
	actor.remove_child(player_instance)
	player_instance.queue_free()

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _handle_pause(paused: bool, actor, blackboard: Blackboard):
	get_tree().paused = paused
	blackboard.set_value("paused", paused)
	
	# instantiate and add the pause scene as a child to the actor if paused
	# remove and free the pause scene otherwise.
	if paused:
		# instantiate the pause scene and add it as a child to the actor
		pause_instance = PAUSE_SCENE.instantiate()
		actor.add_child(pause_instance)
		return
	
	# free the pause scene if it exists
	if not pause_instance:
		return
	actor.remove_child(pause_instance)
	pause_instance.queue_free()
