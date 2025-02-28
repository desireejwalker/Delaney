class_name LaunchTrajectoryIndicator
extends Node3D

const LERP_SPEED: float = 100

var _target_trajectory: Vector3 = Vector3.ZERO
var _trajectory: Vector3:
	set(value):
		_trajectory = value
		_indicator_pivot.scale = Vector3(1, 1, _trajectory.length() * 0.1)
		_indicator_pivot.look_at(global_position + _trajectory)

@onready var _indicator_pivot: Node3D = %IndicatorPivot
@onready var _mesh_instance_3d: MeshInstance3D = %MeshInstance3D

func _process(delta: float) -> void:
	if _target_trajectory.is_zero_approx():
		return
	_trajectory = _trajectory.move_toward(_target_trajectory, LERP_SPEED * delta)

func set_trajectory(trajectory: Vector3):
	_target_trajectory = trajectory
func set_material(material: Material):
	_mesh_instance_3d.mesh.surface_set_material(0, material)
