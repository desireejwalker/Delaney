@tool
extends FSMState


# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	blackboard.set_value("is_moving", true)
	
	actor.velocity.y = 0

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var transitioned = _handle_transition_events(actor)
	if transitioned:
		return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node) -> bool:
	if actor.velocity.is_zero_approx():
		get_parent().fire_event("landing/on_start_idling")
		return true
	
	if Input.is_action_pressed("slide"):
		get_parent().fire_event("landing/on_start_sliding")
		return true
	
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("landing/on_jump")
		return true
	
	if Input.is_action_pressed("run"):
		get_parent().fire_event("landing/on_start_running")
		return true
	else:
		get_parent().fire_event("landing/on_start_walking")
		return true
	
	return false
