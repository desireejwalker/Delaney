class_name AffectorComponent extends Node
## Responsible for managing any functionality that an [Affector] needs.

## the [Affector] parent of this [AffectorComponent].
@onready var affector: Affector = get_parent()

## [override] called when this [Affector] is applied.
func _apply():
	pass
## [override] called on every tick this [Affector] is active.
func _tick():
	pass
## [override] called when this [Affector] ends.
func _end():
	pass
