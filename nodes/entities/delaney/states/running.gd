@tool
extends FSMState

const ACCELERATION: int = 20
const SPEED_MULTIPLIER: float = 2.0
const SKID_THRESHOLD: float = -0.5

@onready var _allow_skidding_delay_timer: Timer = %AllowSkiddingDelayTimer
@onready var _skid_cooldown_timer: Timer = %SkidCooldownTimer
@onready var _running_dust_trail: GPUParticles3D = %RunningDustTrail

func _on_enter(_actor: Node, blackboard: Blackboard) -> void:
	blackboard.set_value("is_moving", true)
	
	# ... self explanatory.
	if get_parent().last_active_state == %Idle or get_parent().last_active_state == %Walking:
		blackboard.set_value("is_skidding_allowed_while_running", false)
	
	# if delaney will skid upon changing directions while running, upon entering this state
	# (likely from the skidding state), enable the dust trail.
	if blackboard.get_value("is_skidding_allowed_while_running"):
		_running_dust_trail.emitting = true
	else:
		# if the blackboard doesn't have this variable yet (likely because delaney entered this
		# state from a state other than skidding, add it and set it to false to avoid any NRE's.
		if blackboard.get_value("is_skidding_allowed_while_running") == null:
			blackboard.set_value("is_skidding_allowed_while_running", false)
		
		_allow_skidding_delay_timer.timeout.connect(_on_allow_skidding_delay_timer_timeout.bind(blackboard))
		if _allow_skidding_delay_timer.paused:
			_allow_skidding_delay_timer.paused = false
			return
		
		_allow_skidding_delay_timer.start()

func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var direction = _handle_direction_input(actor)
	var will_skid = _handle_skidding(actor, blackboard.get_value("is_skidding_allowed_while_running"), direction)
	if will_skid:
		return
	
	var speed = actor.get_entity_stats().get_agility() * SPEED_MULTIPLIER
	var velocity = _handle_running(actor.velocity, direction, speed, delta)
	var velocity_normalized = velocity.normalized()
	
	actor.velocity = velocity
	if velocity_normalized.is_zero_approx():
		return
	
	actor.rotation.y = atan2(velocity_normalized.x, velocity_normalized.z)
	
	var transitioned = _handle_transition_events(actor, blackboard)
	if transitioned:
		return

func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	_running_dust_trail.emitting = false
	
	_allow_skidding_delay_timer.timeout.disconnect(_on_allow_skidding_delay_timer_timeout)
	if not _allow_skidding_delay_timer.is_stopped():
		_allow_skidding_delay_timer.paused = true

func _handle_transition_events(actor: Node, blackboard: Blackboard) -> bool:
	if Input.is_action_pressed("jump"):
		get_parent().fire_event("running/on_jump")
		return true
	
	if not actor.is_on_floor():
		get_parent().fire_event("running/on_start_falling")
		return true
	
	if Input.is_action_pressed("spin"):
		get_parent().fire_event("running/on_start_hammer_launching")
		return true
	
	if Input.is_action_pressed("slide"):
		get_parent().fire_event("running/on_start_sliding")
		return true
	
	if actor.velocity.is_zero_approx():
		blackboard.remove_value("is_skidding_allowed_while_running")
		get_parent().fire_event("running/on_start_idling")
		return true
		
	if not Input.is_action_pressed("run"):
		blackboard.remove_value("is_skidding_allowed_while_running")
		get_parent().fire_event("running/on_start_walking")
		return true
	
	return false

func _handle_direction_input(actor: Node) -> Vector3:
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	return direction

func _handle_skidding(actor: Node, is_skidding_allowed_while_running: bool, direction: Vector3) -> bool:
	if not is_skidding_allowed_while_running or not _skid_cooldown_timer.is_stopped():
		return false
	
	if direction.is_zero_approx():
		get_parent().fire_event("running/on_start_skidding")
		return true
	
	var dot = actor.velocity.normalized().dot(direction)
	if dot <= SKID_THRESHOLD:
		get_parent().fire_event("running/on_start_skidding")
		return true
	
	return false

func _handle_running(current_velocity: Vector3, direction: Vector3, speed: float, delta: float) -> Vector3:
	var velocity = current_velocity.move_toward(direction * speed, ACCELERATION * delta)
	return velocity

func _on_allow_skidding_delay_timer_timeout(blackboard: Blackboard):
	blackboard.set_value("is_skidding_allowed_while_running", true)
	_running_dust_trail.emitting = true
