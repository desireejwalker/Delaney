class_name Affector extends Node
## The parent node of an "AffectorObject", which can be applied as
## buffs or debuffs to an entity with an [AffectorManagerComponent].
##
## Responsible for managing a one-time event. Good for basic damage, health pickups, etc.

## emitted when this [Affector] is applied, passing this [Affector] along to the reciever.
signal on_apply(affector)
## emitted when this [Affector] ends, passing this [Affector] along to the reciever.
signal on_end(affector)

## The [Timer] that will dictate the duration of this [Affector].
## If null, this [Affector] lasts an indefinite amount of time,
## i.e., this [Affector] may only be removed manually.
@export var _duration_timer: Timer

var _is_active: bool = false

## the [AffectorManagerComponent] that is currently managing this [Affector].
var affector_manager_component: AffectorManagerComponent

## the [AffectorComponent]s that this [Affector] is defined by.
var _affector_components: Array = []

func _apply():
	_affector_components = get_children().filter(func(child): return child is AffectorComponent)
	for affector in _affector_components:
		affector._apply()
	
	_is_active = true
	
	if _duration_timer:
		_duration_timer.start()
		_duration_timer.timeout.connect(_end)
	
	on_apply.emit(self)
	print("apply")

func _end():
	for affector_component in _affector_components:
		affector_component._end()
	
	_is_active = false
	
	if _duration_timer:
		_duration_timer.timeout.disconnect(_end)
	
	on_end.emit(self)
	print("tock")
