class_name EntityStatus
extends Resource

var _max_health: int
var _health: int

var _status_effects := []

func get_max_health() -> int:
	return _max_health
func get_health() -> int:
	return _health
