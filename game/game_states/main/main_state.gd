@tool
extends FSMState

const TESTER_100_COMBO_ACTION = preload("res://game/resources/combo_action_entries/tester/tester_100.tres")

const PAUSE_SCENE = preload("res://game/game_states/main/assets/pause/pause_scene.tscn")
const MAIN_UI_SCENE = preload("res://game/game_states/main/assets/ui/main_ui.tscn")
const DELANEY_SCENE = preload("res://nodes/entities/delaney/delaney.tscn")
const MONSTER_SCENE = preload("res://nodes/entities/monsters/monster/monster.tscn")

const COMBO_THRESHOLD: int = 3

@onready var combo_timer: Timer = $ComboTimer

var pause_instance: CanvasLayer
var main_ui_instance: MainUI
var delaney_instance: Delaney

# combo
enum ComboLevel
{
	NONE,
	DELTA,
	EPSILON,
	LAMBDA
}
var combo_multipliers: Dictionary = {
	ComboLevel.NONE: 1.0,
	ComboLevel.DELTA: 1.5,
	ComboLevel.EPSILON: 2.0,
	ComboLevel.LAMBDA: 3.0,
}
var combo_time_limits: Dictionary = {
	ComboLevel.NONE: 5.0,
	ComboLevel.DELTA: 5.0,
	ComboLevel.EPSILON: 3.5,
	ComboLevel.LAMBDA: 2.0
}
var combo_point_thresholds: Dictionary = { ## number of points that need to be gained within the combo level to advance to next combo level
	ComboLevel.NONE: -1,
	ComboLevel.DELTA: 500,
	ComboLevel.EPSILON: 1000,
	ComboLevel.LAMBDA: -1
}
var combo_level: ComboLevel = ComboLevel.NONE:
	set(value):
		combo_level = value
		main_ui_instance.set_combo_level(int(combo_level))
var combo_action_list: Array = []

# points
var total_points: int = 0:
	set(value):
		total_points = value
		if main_ui_instance:
			main_ui_instance.set_target_points(total_points)
var combo_points: int = 0

# Executes after the state is entered.
func _on_enter(actor, blackboard: Blackboard):
	delaney_instance = DELANEY_SCENE.instantiate()
	# set the player's position to be in the middle of the CurrentFloor's StartingRoom
	# multiplied by 16 to account for pixels per unit
	var player_start_position = actor.floor_manager.CurrentFloor.FloorGenerationOutput.StartingRoom.position * 16
	delaney_instance.position = player_start_position
	delaney_instance.did_combo_action.connect(add_combo_action)
	actor.add_child(delaney_instance)
	
	var monster_instance = MONSTER_SCENE.instantiate()
	# set the player's position to be in the middle of the CurrentFloor's StartingRoom
	# multiplied by 16 to account for pixels per unit
	monster_instance.position = actor.floor_manager.CurrentFloor.FloorGenerationOutput.StartingRoom.position * 16 + (Vector2.UP * 50)
	actor.add_child(monster_instance)
	
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
	main_ui_instance.set_player_marker_rotation(delaney_instance.angle_radians)
	main_ui_instance.set_player_marker_position(delaney_instance.position)
	
	# if the menu button was just pressed, toggle paused
	if Input.is_action_just_pressed("menu"):
		_handle_pause(not blackboard.get_value("paused"), actor, blackboard)
	
	# if paused and the quit button was just pressed, fire the on_paused_and_quitted event
	# to clear the floor and return to the title state.
	if blackboard.get_value("paused") and Input.is_action_just_pressed("quit"):
		# unpause just to be safe
		_handle_pause(false, actor, blackboard)
		actor.game_state_machine.fire_event("on_paused_and_quitted")
	
	if Input.is_action_just_pressed("interact"):
		add_combo_action(TESTER_100_COMBO_ACTION)
	
	main_ui_instance.set_combo_time_left(combo_timer.time_left)

# Executes before the state is exited.
func _on_exit(actor, blackboard: Blackboard):
	# remove and free the main ui scene
	actor.remove_child(main_ui_instance)
	main_ui_instance.queue_free()
	
	# remove and free the player
	actor.remove_child(delaney_instance)
	delaney_instance.did_combo_action.disconnect(add_combo_action)
	delaney_instance.queue_free()

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings

# pausing
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

# combo
func add_combo_action(action: ComboActionEntry):
	combo_action_list.append(action)
	main_ui_instance.add_combo_action(action)
	print("recieved combo action \n" + action._to_string())
	add_points(action.points, combo_multipliers[combo_level])
	
	# if the combo timer has no time left on it
	# connect the timeout signal to break_combo()
	if combo_timer.time_left == 0:
		combo_timer.timeout.connect(break_combo)
	
	# if combo_points is greater than the given value for this combo_level
	# advance combo
	if (combo_point_thresholds[combo_level] >= 0) and (combo_points > combo_point_thresholds[combo_level]):
		advance_combo()
	else:
		# start a timeout based on the current combo level
		combo_timer.start(combo_time_limits[combo_level])
	
	# if the combo action list has surpassed the COMBO_THRESHOLD
	# start a combo if one hasn't been started already.
	if combo_action_list.size() < COMBO_THRESHOLD:
		return
	if combo_level != ComboLevel.NONE:
		return
	
	start_combo()

func start_combo():
	combo_level = ComboLevel.DELTA
	
	combo_points = 0
	
	combo_timer.start(combo_time_limits[combo_level])
	main_ui_instance.show_points_overlay()
func advance_combo():
	if combo_level + 1 > ComboLevel.LAMBDA:
		return
	combo_level += 1
	
	combo_points = 0
	
	combo_timer.start(combo_time_limits[combo_level])
func break_combo():
	# downgrade combo every timeout
	# if next downgrade is ComboLevel.NONE
	# reset or sumn idk
	if combo_level - 1 < ComboLevel.DELTA:
		combo_level = ComboLevel.NONE
		combo_action_list = []
		main_ui_instance.queue_clear_combo_actions()
		main_ui_instance.hide_points_overlay()
		combo_timer.timeout.disconnect(break_combo)
		return
	
	combo_level -= 1
	combo_timer.start(combo_time_limits[combo_level])

# total_points
func add_points(points: int, multiplier: float):
	total_points += int(points * multiplier)
	print("added " + str(points) + " multiplied by " + str(multiplier) + "\n new total: " + str(total_points))
	combo_points += points
	print("points gained in this combo: " + str(combo_points))
	
