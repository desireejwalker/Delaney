@tool
class_name StandaloneHitbox
extends Hitbox

func _ready() -> void:
	super()
	damage_instance.source = self
