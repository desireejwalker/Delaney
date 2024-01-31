class_name GameManager extends Node

static var _instance: GameManager

static func get_instance(): return _instance

func _ready():
	if _instance == null:
		_instance = self
