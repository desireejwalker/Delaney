class_name PeriodicAffector extends Affector
## The parent node of an "AffectorObject", which can be applied as
## buffs or debuffs to an entity with an [AffectorManagerComponent].
##
## Responsible for managing a timed effect. Good for making DoTs, potion effects,
## buffs, etc.

## emitted on every tick of this [PeriodicAffector], passing this [PeriodicAffector] along to the reciever.
signal on_tick(affector)

## The [Timer] that will dictate the duration of one "tick" of this [Affector].
@export var _period_timer: Timer

var _internal_period_time: float

func _apply():
	super()
	_period_timer.timeout.connect(_tick)
	_period_timer.start()

func _tick():
	if not _is_active:
		return
	
	for affector in _affector_components:
		affector._tick()
	
	on_tick.emit(self)
	print("tick")

func _end():
	super()
