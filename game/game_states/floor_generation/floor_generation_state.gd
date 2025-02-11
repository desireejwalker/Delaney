@tool
extends FSMState

const LOADING_SCENE = preload("res://game/game_states/floor_generation/loading_scene.tscn")

## Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	# cast actor
	actor = actor as GameManager
	
	# generate a new floor
	actor.floor_manager.GenerateFloor()
	
	# connect the FloorReady signal to this state
	actor.floor_manager.FloorReady.connect(_floor_generated)
	
	# show the loading screen
	blackboard.set_value("loading_screen_instance", LOADING_SCENE.instantiate())
	actor.add_child(blackboard.get_value("loading_screen_instance"))


## Executes every process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass


## Executes before the state is exited.
func _on_exit(actor: Node, blackboard: Blackboard) -> void:
	# cast actor
	actor = actor as GameManager
	
	blackboard.get_value("loading_screen_instance").queue_free()
	
	# disconnect the FloorReady signal from this state
	actor.floor_manager.FloorReady.disconnect(_floor_generated)


func _floor_generated():
	GameManager.get_instance().game_state_machine.fire_event("on_floor_generated")
