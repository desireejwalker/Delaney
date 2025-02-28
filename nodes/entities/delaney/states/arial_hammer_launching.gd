@tool
extends FSMState

const SPEED_RETAINED: float = 4
const ACCELERATION: int = 5

const MAX_VERTICAL_TRAJECTORY: float = deg_to_rad(45)
const MIN_VERTICAL_TRAJECTORY: float = deg_to_rad(-45) 
const TRAJECTORY_HORIZONTAL_SPEED: float = 2.0
const TRAJECTORY_VERTICAL_SPEED: float = 2.0

const BLUNT_ROTATION_SPEED: float = 800.0
const DELTA_ROTATION_SPEED: float = 1200.0
const EPSILON_ROTATION_SPEED: float = 1600.0
const LAMBDA_ROTATION_SPEED: float = 2000.0

@export var _blunt_launch_parameters: LaunchParameters
@export var _delta_launch_parameters: LaunchParameters
@export var _epsilon_launch_parameters: LaunchParameters
@export var _lambda_launch_parameters: LaunchParameters

var _saved_velocity: Vector3
var _target_rotation_speed: float
var _rotation_speed: float
var _launched: bool = false

var _current_launch_parameters: LaunchParameters
var _launch_trajectory: Vector3 = Vector3.FORWARD

var _launch_trajectory_horizontal_rotation: float
var _launch_trajectory_vertical_rotation: float

@onready var _blunt_flow_state: FSMState = %Blunt
@onready var _delta_flow_state: FSMState = %Delta
@onready var _epsilon_flow_state: FSMState = %Epsilon
@onready var _lambda_flow_state: FSMState = %Lambda

@onready var _pivot: Node3D = %Pivot
@onready var _launch_trajectory_indicator: LaunchTrajectoryIndicator = %LaunchTrajectoryIndicator
@onready var _arial_hammer_launch_delay_timer: Timer = %ArialHammerLaunchDelayTimer
@onready var _hammer_animation_player: AnimationPlayer = %HammerAnimationPlayer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	var flow_state_finite_state_machine: FiniteStateMachine = actor.get_flow_state_finite_state_machine()
	
	blackboard.set_value("is_moving", true)
	
	_saved_velocity = Vector3(actor.velocity)
	actor.velocity = actor.velocity.limit_length(SPEED_RETAINED)
	
	var current_flow_state = flow_state_finite_state_machine.active_state
	
	_rotation_speed = 0
	_target_rotation_speed = BLUNT_ROTATION_SPEED
	match current_flow_state:
		_delta_flow_state:
			_target_rotation_speed = DELTA_ROTATION_SPEED
		_epsilon_flow_state:
			_target_rotation_speed = EPSILON_ROTATION_SPEED
		_lambda_flow_state:
			_target_rotation_speed = LAMBDA_ROTATION_SPEED
	
	_blunt_flow_state.on_update.connect(_on_blunt_flow_state_update)
	_delta_flow_state.on_update.connect(_on_delta_flow_state_update)
	_epsilon_flow_state.on_update.connect(_on_epsilon_flow_state_update)
	_lambda_flow_state.on_update.connect(_on_lambda_flow_state_update)
	
	_launch_trajectory = Vector3.FORWARD
	_launch_trajectory_horizontal_rotation = actor.get_camera().get_camera().global_transform.basis.get_euler().y
	_launch_trajectory_vertical_rotation = actor.get_camera().get_camera().global_transform.basis.get_euler().x
	
	_hammer_animation_player.play("hammer_launching")
	
	_launch_trajectory_indicator.visible = true
	
	_arial_hammer_launch_delay_timer.timeout.connect(_on_arial_hammer_launch_delay_timer_timeout.bind(actor, blackboard))
	_arial_hammer_launch_delay_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	#print(_arial_hammer_launch_delay_timer.time_left)
	
	if not Input.is_action_pressed("spin") and not _launched:
		get_parent().fire_event("arial_hammer_launching/on_start_falling")
		return
	
	if actor.is_on_floor():
		get_parent().fire_event("arial_hammer_launching/on_start_hammer_launching")
		return
	
	actor.velocity = actor.velocity.move_toward(actor.velocity.limit_length(SPEED_RETAINED), ACCELERATION * delta)
	
	_rotation_speed = lerp(_rotation_speed, _target_rotation_speed, delta * 2)
	_handle_spin(actor, delta, _rotation_speed)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	_launched = false
	
	if not _arial_hammer_launch_delay_timer.is_stopped():
		actor.velocity = _saved_velocity
	
	_blunt_flow_state.on_update.disconnect(_on_blunt_flow_state_update)
	_delta_flow_state.on_update.disconnect(_on_delta_flow_state_update)
	_epsilon_flow_state.on_update.disconnect(_on_epsilon_flow_state_update)
	_lambda_flow_state.on_update.disconnect(_on_lambda_flow_state_update)
	
	_launch_trajectory_indicator.visible = false
	
	_arial_hammer_launch_delay_timer.timeout.disconnect(_on_arial_hammer_launch_delay_timer_timeout)
	_hammer_animation_player.play("rest")

func _handle_launch_trajectory(actor: Node, delta: float, speed: float):
	actor = actor as DelaneyEntity
	
	var horizontal_input = Input.get_action_strength("launch_left") - Input.get_action_strength("launch_right")
	var vertical_input = Input.get_action_strength("launch_up") - Input.get_action_strength("launch_down")
	var input = Vector2(horizontal_input, vertical_input)
	
	_launch_trajectory_horizontal_rotation += (input.x * delta * TRAJECTORY_HORIZONTAL_SPEED)
	_launch_trajectory_vertical_rotation += (input.y * delta * TRAJECTORY_VERTICAL_SPEED)
	_launch_trajectory_vertical_rotation = clamp(
		_launch_trajectory_vertical_rotation,
		MIN_VERTICAL_TRAJECTORY,
		MAX_VERTICAL_TRAJECTORY)
	
	_launch_trajectory = Vector3.FORWARD.rotated(Vector3.RIGHT, _launch_trajectory_vertical_rotation).normalized()
	_launch_trajectory = _launch_trajectory.rotated(Vector3.UP, _launch_trajectory_horizontal_rotation).normalized()
	_launch_trajectory *= speed

func _update_launch_trajectory_indicator(launch_trajectory: Vector3, material: Material = null):
	_launch_trajectory_indicator.set_trajectory(launch_trajectory)
	if material:
		_launch_trajectory_indicator.set_material(material)

func _handle_spin(actor: Node, delta: float, speed: float):
	_pivot.rotation_degrees.y = _pivot.rotation_degrees.y + (speed * delta)

func _handle_launch(actor: Node, blackboard: Blackboard) -> bool:
	actor = actor as DelaneyEntity
	
	var current_flow_state = actor.get_flow_state_finite_state_machine().active_state
	match current_flow_state:
		_blunt_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _blunt_launch_parameters)
			get_parent().fire_event("arial_hammer_launching/on_launch")
			return true
		_delta_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _delta_launch_parameters)
			get_parent().fire_event("arial_hammer_launching/on_launch")
			return true
		_epsilon_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _epsilon_launch_parameters)
			get_parent().fire_event("arial_hammer_launching/on_launch")
			return true
		_lambda_flow_state:
			blackboard.set_value("current_launch_trajectory", _launch_trajectory)
			blackboard.set_value("current_launch_parameters", _lambda_launch_parameters)
			get_parent().fire_event("arial_hammer_launching/on_launch")
			return true
		_:
			return false

func _on_arial_hammer_launch_delay_timer_timeout(actor: Node, blackboard: Blackboard):
	_launched = _handle_launch(actor, blackboard)

func _on_blunt_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, delta, _blunt_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _blunt_launch_parameters.get_launch_trajectory_indicator_material())
func _on_delta_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, delta, _delta_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _delta_launch_parameters.get_launch_trajectory_indicator_material())
func _on_epsilon_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, delta, _epsilon_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _epsilon_launch_parameters.get_launch_trajectory_indicator_material())
func _on_lambda_flow_state_update(delta, actor, blackboard):
	_handle_launch_trajectory(actor, delta, _lambda_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(_launch_trajectory, _lambda_launch_parameters.get_launch_trajectory_indicator_material())
