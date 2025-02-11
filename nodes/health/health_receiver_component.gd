class_name HealthReceiverComponent extends Node
## Responsible for recieving healing and relaying that information
## to other nodes.

## emitted whenever healing is recieved.
signal on_healed(healing_amount: int)

## if true, this component will print info about the healing recieved.
@export var _print_info_on_healing_recieved: bool = false
## the [HealthComponent] that will take the health recieved.
@export var _health_component: HealthComponent

## calls [method HealthComponent.add_health] with [param healing_amount] passed as the amount.
## Afterwards, emits [signal on_healed] the same way.
func heal(healing_amount: int):
	if _print_info_on_healing_recieved:
		print("Healed - Amount: {healing_amount}".format({"healing_amount":str(healing_amount)}))
	
	_health_component.add_health(healing_amount)
	on_healed.emit(healing_amount)
