class_name EntityStats
extends Resource

@export var _health: int
@export var _damage: int
@export var _agility: int

func get_health() -> int:
	return _health
func get_damage() -> int:
	return _damage
func get_agility() -> int:
	return _agility
