@tool
extends FSMState

const LOADING_SCENE = preload("res://game/game_states/floor_generation/loading_scene.tscn")
var loading_scene_instance

# Executes after the state is entered.
func _on_enter(actor, _blackboard: Blackboard):
	# clear the floor
	actor.floor_manager.ClearFloor()
	
	# show the loading screen
	#loading_scene_instance = LOADING_SCENE.instantiate()
	#actor.add_child(loading_scene_instance)
	
	# fire the on_return_to_title event
	GameManager.get_instance().game_state_machine.fire_event("on_return_to_title")


# Executes every _process call, if the state is active.
func _on_update(_delta, _actor, _blackboard: Blackboard):
	pass


# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

