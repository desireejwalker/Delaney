class_name GameManager extends Node

@onready var game_state_machine: FiniteStateMachine = $GameStateMachine
@onready var floor_manager = $FloorManager

@export var auto_start: bool = false

static var _instance: GameManager
static func get_instance(): return _instance

func _ready():
	if _instance == null:
		_instance = self
	
	if auto_start:
		game_state_machine.change_state($GameStateMachine/FloorGenerationState)

func _prepare_game():
	pass

func quit_game():
	get_tree().quit()
