class_name GameManager extends Node

@onready var game_state_machine = $GameStateMachine
@onready var floor_manager = $FloorManager

static var _instance: GameManager
static func get_instance(): return _instance

func _ready():
	if _instance == null:
		_instance = self

func _prepare_game():
	pass

func quit_game():
	get_tree().quit()
