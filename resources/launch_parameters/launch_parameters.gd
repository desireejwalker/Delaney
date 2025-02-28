class_name LaunchParameters extends Resource

@export var _trail_particle_system: PackedScene
@export var _launch_trajectory_indicator_material: Material
@export var _speed: float
@export var _duration_seconds: float
@export var _does_ricochet: bool

func get_trail_particle_system() -> PackedScene:
	return _trail_particle_system
func get_launch_trajectory_indicator_material() -> Material:
	return _launch_trajectory_indicator_material
func get_speed() -> float:
	return _speed
func get_duration_seconds() -> float:
	return _duration_seconds
func does_ricochet() -> bool:
	return _does_ricochet
