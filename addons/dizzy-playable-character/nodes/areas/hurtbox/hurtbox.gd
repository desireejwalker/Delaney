@tool
class_name Hurtbox
extends Area3D
## Area class for [Hitbox] detection.

## Emitted when this [Hurtbox] is intersected by a [Hitbox].
signal hit(hitbox: Hitbox)

# @export var status_interface: StatusInterface
@export var shape: BoxShape3D:
	set(value):
		shape = value
		%CollisionShape3D.shape = shape

func _on_area_entered(area: Area3D) -> void:
	# the only areas that should be able to interact with
	# a hurtbox is a hitbox (due to the collision layers)
	# but just in case we'll run this check.
	var hitbox = area as Hitbox
	if not hitbox:
		return
	
	if not hitbox.try_consume():
		return
	
	hit.emit(hitbox)
	# var damage_instance = hitbox.consume()
	# var status = status_interface.get_status()
	# status.damage(damage_instance)
