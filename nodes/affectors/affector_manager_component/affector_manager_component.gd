class_name AffectorManagerComponent extends Node
## Responsible for managing [Affector]s and their effects on
## entities.

## the [HealthReceiverComponent] that this [AffectorManagerComponent] may access.
@export var health_receiver_component: HealthReceiverComponent
## the [DamageReceiverComponent] that this [AffectorManagerComponent] may access.
@export var damage_receiver_component: DamageReceiverComponent

var _affectors: Array = []

## applies [Affector] [param affector] to the entity.
func add_affector(affector: Affector):
	if _affectors.has(affector):
		return
	
	add_child(affector)
	_affectors.append(affector)
	affector.affector_manager_component = self
	affector._apply()
	
	affector.on_end.connect(_remove_affector)

## removes [Affector] [param affector] from the entity and frees it.
func _remove_affector(affector: Affector):
	if not _affectors.has(affector):
		return
	
	_affectors.erase(affector)
	remove_child(affector)
	
	affector.queue_free()

## ends all [Affector]s.
func end_all_affectors():
	for affector in _affectors:
		affector._end()
