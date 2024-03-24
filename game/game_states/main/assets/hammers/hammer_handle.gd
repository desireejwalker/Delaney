class_name HammerHandle extends Area2D

signal on_hit(other: Node2D)

const POSITION_WEIGHT: float = 100
const ROTATION_WEIGHT: float = 50

@export var sprite: Sprite2D
@export var trail: Trail2D
@export var hitbox: CollisionShape2D

var target_position: Vector2
var target_rotation_rad: float

func _on_body_entered(other: Node2D):
	on_hit.emit(other)

func _process(delta):
	position = position.move_toward(target_position, delta * POSITION_WEIGHT)
	rotation = lerp_angle(rotation, target_rotation_rad, delta * ROTATION_WEIGHT)
