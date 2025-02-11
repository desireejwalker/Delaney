class_name DepleteHealthAffectorComponent extends AffectorComponent

@export var damage_amount: int

var damage_receiver_component: DamageReceiverComponent 

func _apply():
	damage_receiver_component = owner.affector_manager_component.damage_receiver_component

func _tick():
	damage_receiver_component.damage(damage_amount)
