@tool
extends FSMState

const SKID_TRAIL_SCENE = preload("res://nodes/particle_systems/trails/PAR_T_skid-trail.tscn")

@onready var _skid_timer: Timer = %SkidTimer
@onready var _skid_cooldown_timer: Timer = %SkidCooldownTimer

var _skid_trail_instance

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	blackboard.set_value("is_moving", true)
	
	#_skid_trail_instance = SKID_TRAIL_SCENE.instantiate()
	#actor.add_child(_skid_trail_instance)
	
	var velocity = Vector3(actor.velocity.x * 0.5, actor.velocity.y, actor.velocity.z * 0.5)
	actor.velocity = velocity
	
	_skid_timer.timeout.connect(_on_skid_timer_timeout)
	_skid_timer.start()
	_skid_cooldown_timer.start()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if not _skid_timer.is_stopped():
		return
	
	if Input.is_action_pressed("move"):
		if Input.is_action_pressed("run"):
			get_parent().fire_event("on_start_running")
			return
		get_parent().fire_event("on_start_walking")
		return
	
	actor.velocity = Vector3.ZERO
	get_parent().fire_event("on_start_idling")
	return

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	_skid_timer.timeout.disconnect(_on_skid_timer_timeout)
	
	#_skid_trail_instance.queue_free()

func _on_skid_timer_timeout():
	pass
