@tool
extends FSMState

const TITLE_SCENE: PackedScene = preload("res://game/game_states/title/title_scene.tscn")

var title_scene_instance: Title

# Executes after the state is entered.
func _on_enter(actor, _blackboard: Blackboard):	
	# instantiate the title scene and add it as child to the GameManager
	title_scene_instance = TITLE_SCENE.instantiate()
	actor.add_child.call_deferred(title_scene_instance)
	
	# connect the button signals to the state
	title_scene_instance.start_button_pressed.connect(_start_button_pressed)
	title_scene_instance.quit_button_pressed.connect(_quit_button_pressed)


# Executes every _process call, if the state is active.
func _on_update(_delta, _actor, _blackboard: Blackboard):
	pass


# Executes before the state is exited.
func _on_exit(actor, _blackboard: Blackboard):
	# remove the title scene from the GameManager
	actor.remove_child(title_scene_instance)
	
	# disconnect the button signals from the state
	title_scene_instance.start_button_pressed.disconnect(_start_button_pressed)
	title_scene_instance.quit_button_pressed.disconnect(_quit_button_pressed)
	
	# finally free the title scene
	title_scene_instance.queue_free()


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

func _start_button_pressed():
	print("start")
	GameManager.get_instance().game_state_machine.fire_event("start_button_pressed")
func _quit_button_pressed():
	print("quit")
	GameManager.get_instance().quit_game()
