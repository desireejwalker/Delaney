class_name HealthComponent extends Node
## Responsible for managing and manipulating health.

## emitted when [member _current_health] is increased by [method add_health].
signal on_current_health_incremented
## emitted when [member _current_health] is decreased by [method subtract_health].
signal on_current_health_decremented
## emitted when [member _current_health] is zero. (0)
signal on_current_health_depleted

## the maximum value that [member _current_health] can be.
@export var _max_health: int = 5
## if true, [member _current_health] will start at [member _max_health].
@export var _start_at_max_health: bool = false

## the actual health value of this [HealthComponent]
var _current_health: int:
	set(value):
		_current_health = value
		
		# keep health from going over max health
		if _current_health > _max_health:
			_current_health = _max_health
		# keep health from going below zero
		if _current_health < 0:
			_current_health = 0
			on_current_health_depleted.emit()

func _ready():
	if not _start_at_max_health:
		return
	_current_health = _max_health

## adds [param value] health to [member _current_health] and emits [signal on_current_health_incremented].
func add_health(value: int):
	_current_health += value
	on_current_health_incremented.emit()
## subtract [param value] health to [member _current_health] and emits [signal on_current_health_decremented].
func subtract_health(value: int):
	_current_health -= value
	on_current_health_decremented.emit()

func _set_health(value: int):
	_current_health = value
## returns [member _currrent_health]
func get_health() -> int:
	return _current_health
