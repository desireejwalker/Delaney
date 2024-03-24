class_name Hammer extends Node2D

@onready var hammer_animation_player = $HammerAnimationPlayer

@export_category("Weights")
@export var position_weight := 1.0
@export var rotation_weight := 1.0

var target_local_position := Vector2.ZERO
var target_rotation_degrees := 0.0

enum HammerSpriteRotation
{
	SOUTH,
	SOUTHEAST,
	EAST,
	NORTHEAST,
	NORTH,
	NORTHWEST,
	WEST,
	SOUTHWEST,
}
var sprite_rotation := HammerSpriteRotation.SOUTH

func set_target_local_position(target_local_position: Vector2):
	self.target_local_position = target_local_position
func set_target_rotation(target_rotation_degrees: float):
	self.target_rotation_degrees = target_rotation_degrees
func set_sprite_rotation(sprite_rotation: HammerSpriteRotation):
	self.sprie_rotation = sprite_rotation

func _process(delta):
	position = position.lerp(target_local_position, position_weight * delta)
	rotation_degrees = lerpf(rotation_degrees, target_rotation_degrees, rotation_weight * delta)

