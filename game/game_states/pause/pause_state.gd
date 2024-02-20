@tool
extends FSMState

const PAUSE_SCENE = preload("res://game/game_states/main/assets/pause/pause_scene.tscn")
var pause_instance: CanvasLayer

## Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	# pause the scene tree
	get_tree().paused = true
	
	# instantiate the pause scene and add it as a child to the actor
	pause_instance = PAUSE_SCENE.instantiate()
	actor.add_child(pause_instance)


## Executes every process call, if the state is active.
func _on_update(_delta: float, actor: Node, _blackboard: Blackboard) -> void:
	# if the menu button was just pressed, unpause
	if Input.is_action_just_pressed("menu"):
		actor.game_state_machine.fire_event("on_unpaused")
	# if quit button was just pressed, return to the title screen
	if Input.is_action_just_pressed("quit"):
		print("quit")
		actor.game_state_machine.fire_event("on_paused_and_quitted")


## Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: Blackboard) -> void:
	# free the pause scene
	actor.remove_child(pause_instance)
	pause_instance.queue_free()
	
	# unuse the scene tree
	get_tree().paused = false
