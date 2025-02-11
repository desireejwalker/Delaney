class_name DamageReceiverComponent extends Node
## Responsible for recieving damage and relaying that information
## to other nodes.

## emitted whenever damage is recieved.
signal on_damaged(damage_amount: int)

## if true, this component will print info about the damage recieved.
@export var _print_info_on_damage_recieved: bool = false
## the [HealthComponent] that will take the damage recieved.
@export var _health_component: HealthComponent

## calls [method HealthComponent.subtract_health] with [param damage_amount] passed as the amount.
## Afterwards, emits [signal on_damaged] the same way.
func damage(damage_amount: int):
	if _print_info_on_damage_recieved:
		print("Damaged - Amount: {damage_amount}".format({"damage_amount":str(damage_amount)}))
	
	_health_component.subtract_health(damage_amount)
	on_damaged.emit(damage_amount)
