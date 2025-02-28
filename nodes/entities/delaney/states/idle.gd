@tool
extends FSMState

func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	pass

func _on_update(_delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var transitioned = _handle_transition_events(actor)
	if transitioned:
		return

func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_transition_events(actor: Node) -> bool:
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("idle/on_jump")
		return true
	
	if Input.is_action_pressed("spin"):
		get_parent().fire_event("idle/on_start_hammer_launching")
		return true
	
	if (Input.is_action_pressed("move")):
		if (Input.is_action_pressed("run")):
			get_parent().fire_event("idle/on_start_running")
		
		get_parent().fire_event("idle/on_start_walking")
		return true
	
	return false
