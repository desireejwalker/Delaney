class_name DeathComponent extends Node
## Responsible for handling the death of an entity and instantiating
## any visuals needed for death FX (particles, etc.)

## emitted on death.
signal on_death

var _is_dead: bool = false

## list containing any extra nodes that should be freed on death.
@export var _nodes_to_free: Array[Node]
## [AnimationPlayer] that has an animation named "death" that will play when the method [method die] is called.
@export var _animation_player: AnimationPlayer

## kills the entity, freeing any nodes in [member _nodes_to_free], and plays the "death" animation on [member _animation_player].
func die():
	on_death.emit()
	_is_dead = true
	for node in _nodes_to_free:
		if not node:
			continue
		node.queue_free()
	_animation_player.play("death")

func _free_parent_node():
	get_parent().queue_free()
