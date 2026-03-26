@tool
class_name EntityHurtbox
extends Hurtbox

var entity: Entity

func initialize(entity: Entity) -> void:
	self.entity = entity
