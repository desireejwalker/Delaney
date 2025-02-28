@tool
extends FSMState

const PAR_B_DELTA_FLOW_STATE_BURST_SCENE = preload("res://nodes/particle_systems/bursts/PAR_B_delta-flow-state-burst.tscn")
const PAR_B_EPSILON_FLOW_STATE_BURST_SCENE = preload("res://nodes/particle_systems/bursts/PAR_B_epsilon-flow-state-burst.tscn")
const PAR_B_LAMBDA_FLOW_STATE_BURST_SCENE = preload("res://nodes/particle_systems/bursts/PAR_B_lambda-flow-state-burst.tscn")

const ACCELERATION: int = 2

const TO_DELTA_STATE_WAIT_TIME: float = 1.0
const TO_EPSILON_STATE_WAIT_TIME: float = 1.5
const TO_LAMBDA_STATE_WAIT_TIME: float = 2.0

const BLUNT_ROTATION_SPEED: float = 400.0
const DELTA_ROTATION_SPEED: float = 800.0
const EPSILON_ROTATION_SPEED: float = 1200.0
const LAMBDA_ROTATION_SPEED: float = 1600.0

@export var _blunt_launch_parameters: LaunchParameters
@export var _delta_launch_parameters: LaunchParameters
@export var _epsilon_launch_parameters: LaunchParameters
@export var _lambda_launch_parameters: LaunchParameters

var _next_flow_state: FSMState
var _rotation_speed: float

var _current_launch_parameters: LaunchParameters
var _launch_trajectory: Vector3 = Vector3.FORWARD

@onready var _blunt_flow_state: FSMState = %Blunt
@onready var _delta_flow_state: FSMState = %Delta
@onready var _epsilon_flow_state: FSMState = %Epsilon
@onready var _lambda_flow_state: FSMState = %Lambda

@onready var _flow_states = [
	_blunt_flow_state,
	_delta_flow_state,
	_epsilon_flow_state,
	_lambda_flow_state
]

@onready var _pivot: Node3D = %Pivot
@onready var _launch_trajectory_indicator: LaunchTrajectoryIndicator = %LaunchTrajectoryIndicator
@onready var _flow_state_change_timer: Timer = %FlowStateChangeTimer
@onready var _hammer_animation_player: AnimationPlayer = %HammerAnimationPlayer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	var flow_state_finite_state_machine: FiniteStateMachine = actor.get_flow_state_finite_state_machine()
	
	blackboard.set_value("is_moving", true)
	
	var current_flow_state = flow_state_finite_state_machine.active_state
	if not _get_previous_flow_state(current_flow_state) == current_flow_state:
		current_flow_state = _get_previous_flow_state(current_flow_state)
		flow_state_finite_state_machine.change_state(current_flow_state)
	
	_blunt_flow_state.on_update.connect(_on_blunt_flow_state_update)
	_delta_flow_state.on_update.connect(_on_delta_flow_state_update)
	_epsilon_flow_state.on_update.connect(_on_epsilon_flow_state_update)
	_lambda_flow_state.on_update.connect(_on_lambda_flow_state_update)
	
	_launch_trajectory_indicator.visible = true
	
	_next_flow_state = _get_next_flow_state(current_flow_state)
	_flow_state_change_timer.start(TO_DELTA_STATE_WAIT_TIME)
	
	_hammer_animation_player.play("hammer_launching")

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	if not Input.is_action_pressed("spin"):
		var launched = _handle_launch(actor, blackboard)
		return
	
	if not actor.is_on_floor():
		get_parent().fire_event("hammer_launching/on_start_arial_hammer_launching")
		return
	
	_handle_movement(actor, delta)
	_handle_flow_states(actor, blackboard)
	_handle_spin(actor, delta, _rotation_speed)

# Executes before the state is exited.
func _on_exit(_actor: Node, blackboard: Blackboard) -> void:
	#blackboard.set_value("flow_state", DelaneyEntity.FlowState.STATE_BLUNT)
	
	_blunt_flow_state.on_update.disconnect(_on_blunt_flow_state_update)
	_delta_flow_state.on_update.disconnect(_on_delta_flow_state_update)
	_epsilon_flow_state.on_update.disconnect(_on_epsilon_flow_state_update)
	_lambda_flow_state.on_update.disconnect(_on_lambda_flow_state_update)
	
	_launch_trajectory_indicator.visible = false
	
	_hammer_animation_player.play("rest")

func _handle_movement(actor: Node, delta: float):
	actor = actor as DelaneyEntity
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	if direction.is_zero_approx():
		actor.velocity = actor.velocity.move_toward(Vector3.ZERO, ACCELERATION * delta)
	else:
		actor.velocity = actor.velocity.move_toward((direction * actor.get_entity_stats().get_agility()), ACCELERATION * delta)

func _handle_launch_trajectory(actor: Node, speed: float):
	actor = actor as DelaneyEntity
	
	var h_rot = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	if direction.is_zero_approx():
		direction = Vector3.FORWARD.rotated(Vector3.UP, h_rot)
	
	_launch_trajectory = direction * speed
func _update_launch_trajectory_indicator(launch_trajectory: Vector3, material: Material = null):
	_launch_trajectory_indicator.set_trajectory(launch_trajectory)
	if material:
		_launch_trajectory_indicator.set_material(material)
	
# handle advancing to higher launch levels (up to 3)
func _handle_flow_states(actor: Node, blackboard: Blackboard):
	actor = actor as DelaneyEntity
	
	match _next_flow_state:
		_delta_flow_state:
			if _flow_state_change_timer.time_left == 0:
				blackboard.set_value("flow_state", _next_flow_state)
				actor.get_flow_state_finite_state_machine().change_state(_next_flow_state)
				_next_flow_state = _get_next_flow_state(_next_flow_state)
				
				# increase the heavy_attack_speed to make delaney spin faster
				_rotation_speed = DELTA_ROTATION_SPEED
				
				var burst = PAR_B_DELTA_FLOW_STATE_BURST_SCENE.instantiate()
				actor.add_child(burst)
				burst.get_node("%AnimationPlayer").play("self_destruct")
				
				# start the heavy_attack_timer at 1.5 to wait that amount of seconds
				# before advancing to launch_level 2
				_flow_state_change_timer.start(TO_EPSILON_STATE_WAIT_TIME)
			else:
				_rotation_speed = BLUNT_ROTATION_SPEED
		_epsilon_flow_state:
			if _flow_state_change_timer.time_left == 0:
				blackboard.set_value("flow_state", _next_flow_state)
				actor.get_flow_state_finite_state_machine().change_state(_next_flow_state)
				_next_flow_state = _get_next_flow_state(_next_flow_state)
				
				# increase the heavy_attack_speed to make delaney spin faster
				_rotation_speed = EPSILON_ROTATION_SPEED
				
				var burst = PAR_B_EPSILON_FLOW_STATE_BURST_SCENE.instantiate()
				actor.add_child(burst)
				burst.get_node("%AnimationPlayer").play("self_destruct")
				
				# start the heavy_attack_timer at 2.0 to wait that amount of seconds
				# before advancing to launch_level 3
				_flow_state_change_timer.start(TO_LAMBDA_STATE_WAIT_TIME)
			else:
				_rotation_speed = DELTA_ROTATION_SPEED
		_lambda_flow_state:
			if _flow_state_change_timer.time_left == 0:
				blackboard.set_value("flow_state", _next_flow_state)
				actor.get_flow_state_finite_state_machine().change_state(_next_flow_state)
				# just set next launch level to 4 to keep from hitting this case over
				# and over again
				_next_flow_state = null
				
				# increase the heavy_attack_speed to make delaney spin faster
				_rotation_speed = LAMBDA_ROTATION_SPEED
				
				var burst = PAR_B_LAMBDA_FLOW_STATE_BURST_SCENE.instantiate()
				actor.add_child(burst)
				burst.get_node("%AnimationPlayer").play("self_destruct")
			else:
				_rotation_speed = EPSILON_ROTATION_SPEED
func _handle_spin(actor: Node, delta: float, speed: float):	
	_pivot.rotation_degrees.y = _pivot.rotation_degrees.y + (speed * delta)
func _handle_launch(actor: Node, blackboard: Blackboard) -> bool:
	actor = actor as DelaneyEntity
	
	var current_flow_state = actor.get_flow_state_finite_state_machine().active_state
	match current_flow_state:
		_blunt_flow_state:
			if actor.velocity.is_zero_approx():
				get_parent().fire_event("hammer_launching/on_start_idling")
				return false
			if Input.is_action_pressed("run"):
				get_parent().fire_event("hammer_launching/on_start_running")
				return false
			else:
				get_parent().fire_event("hammer_launching/on_start_walking")
				return false
		_delta_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _delta_launch_parameters)
			get_parent().fire_event("hammer_launching/on_launch")
			return true
		_epsilon_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _epsilon_launch_parameters)
			get_parent().fire_event("hammer_launching/on_launch")
			return true
		_lambda_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _lambda_launch_parameters)
			get_parent().fire_event("hammer_launching/on_launch")
			return true
		_:
			return false

func _get_next_flow_state(current_flow_state: FSMState):
	var current_flow_state_index = _flow_states.find(current_flow_state)
	var next_flow_state_index = current_flow_state_index + 1
	if next_flow_state_index >= _flow_states.size():
		next_flow_state_index = current_flow_state_index
	
	return _flow_states[next_flow_state_index]
func _get_previous_flow_state(current_flow_state: FSMState):
	var current_flow_state_index = _flow_states.find(current_flow_state)
	var next_flow_state_index = current_flow_state_index - 1
	if next_flow_state_index < 0:
		next_flow_state_index = current_flow_state_index
	
	return _flow_states[next_flow_state_index]

func _on_blunt_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, _blunt_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _blunt_launch_parameters.get_launch_trajectory_indicator_material())
func _on_delta_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, _delta_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _delta_launch_parameters.get_launch_trajectory_indicator_material())
func _on_epsilon_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, _epsilon_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _epsilon_launch_parameters.get_launch_trajectory_indicator_material())
func _on_lambda_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, _lambda_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _lambda_launch_parameters.get_launch_trajectory_indicator_material())
