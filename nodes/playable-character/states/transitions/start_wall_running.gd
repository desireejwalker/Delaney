@tool
extends FSMTransition

# Components

@onready var shape_cast: ShapeCast3D = %WallRunningShapeCast3D

# Evaluates true, if the transition conditions are met.
func is_valid(actor: Node, _blackboard: Blackboard) -> bool:
	actor = actor as PlayableCharacter

	if not shape_cast.is_colliding():
		return false
	if get_parent().get_parent().last_active_state == %WallRunning:
		return false
	if not actor.is_on_wall_only():
		return false
	
	return Input.is_action_pressed("run")
