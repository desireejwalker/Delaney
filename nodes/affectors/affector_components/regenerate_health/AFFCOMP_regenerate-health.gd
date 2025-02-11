extends AffectorComponent

@export var healing_amount: int

func _tick():
	affector.affector_manager_component.health_receiver_component.heal(healing_amount)
