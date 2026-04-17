@tool
extends FSMState

const ON_ADVANCE_TO_DELTA: String = "on_advance_to_delta"
const ON_ADVANCE_TO_EPSILON: String = "on_advance_to_epsilon"
const ON_ADVANCE_TO_LAMBDA: String = "on_advance_to_lambda"

const CURRENT_LAUNCH_TRAJECTORY: String = "current_launch_trajectory"
const ARIAL_ACTIONS_STRING: String = "arial_actions"

# Flow States

@export_category("Flow States")
@export_group("Rotation Speed")
@export var blunt_rotation_speed: float = 800.0
@export var delta_rotation_speed: float = 1200.0
@export var epsilon_rotation_speed: float = 1600.0
@export var lambda_rotation_speed: float = 2000.0

@export_group("Launch Parameters")
@export var blunt_launch_parameters: LaunchParameters
@export var delta_launch_parameters: LaunchParameters
@export var epsilon_launch_parameters: LaunchParameters
@export var lambda_launch_parameters: LaunchParameters

# Gameplay Parameters

@export_category("Gameplay Parameters")
@export_group("Movement Speed")
@export var acceleration: float = 5
@export var speed_retained: float = 4
@export var speed: float = 10

@export_group("Trajectory")
@export var max_vertical_trajectory_degrees: float = 45
@export var min_vertical_trajectory_degrees: float = -45
@export var trajectory_horizontal_speed: float = 2.0
@export var trajectory_vertical_speed: float = 2.0

var saved_velocity: Vector3
var target_rotation_speed: float
var rotation_speed: float
var launched: bool = false

var current_launch_parameters: LaunchParameters
var launch_trajectory: Vector3 = Vector3.FORWARD

var launch_trajectory_horizontal_rotation: float
var launch_trajectory_vertical_rotation: float

@onready var blunt_flow_state: FSMState = %Blunt
@onready var delta_flow_state: FSMState = %Delta
@onready var epsilon_flow_state: FSMState = %Epsilon
@onready var lambda_flow_state: FSMState = %Lambda

# Components

@onready var flow_state_finite_state_machine: PlayableCharacterFiniteStateMachine = %PlayableCharacterFlowStateFiniteStateMachine
@onready var launch_trajectory_indicator: LaunchTrajectoryIndicator = %LaunchTrajectoryIndicator
@onready var arial_hammer_launch_delay_timer: Timer = %ArialHammerLaunchDelayTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	_update_arial_actions(blackboard)
	
	saved_velocity = Vector3(actor.velocity)
	actor.mover.set_velocity(actor.velocity.limit_length(speed_retained))

	var current_flow_state = flow_state_finite_state_machine.finite_state_machine.active_state
	rotation_speed = 0
	target_rotation_speed = blunt_rotation_speed
	match current_flow_state:
		delta_flow_state:
			target_rotation_speed = delta_rotation_speed
		epsilon_flow_state:
			target_rotation_speed = epsilon_rotation_speed
		lambda_flow_state:
			target_rotation_speed = lambda_rotation_speed
	
	blunt_flow_state.on_update.connect(_on_blunt_flow_state_update)
	delta_flow_state.on_update.connect(_on_delta_flow_state_update)
	epsilon_flow_state.on_update.connect(_on_epsilon_flow_state_update)
	lambda_flow_state.on_update.connect(_on_lambda_flow_state_update)
	

	launch_trajectory = Vector3.FORWARD
	launch_trajectory_horizontal_rotation = actor.camera.camera.global_transform.basis.get_euler().y
	launch_trajectory_vertical_rotation = actor.camera.camera.global_transform.basis.get_euler().x
	launch_trajectory_indicator.visible = true
	
	# hammer_animation_player.play("hammer_launching")

	arial_hammer_launch_delay_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	actor.mover.set_velocity(actor.velocity.move_toward(actor.velocity.limit_length(speed_retained), acceleration * delta))
	
	rotation_speed = lerp(rotation_speed, target_rotation_speed, delta * 2)
	_handle_spin(actor, delta, rotation_speed)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	if not arial_hammer_launch_delay_timer.is_stopped():
		actor.mover.set_velocity(saved_velocity)
		actor.mover.set_direction(saved_velocity.normalized())
	
	blunt_flow_state.on_update.disconnect(_on_blunt_flow_state_update)
	delta_flow_state.on_update.disconnect(_on_delta_flow_state_update)
	epsilon_flow_state.on_update.disconnect(_on_epsilon_flow_state_update)
	lambda_flow_state.on_update.disconnect(_on_lambda_flow_state_update)
	
	launch_trajectory_indicator.visible = false

	blackboard.set_value(CURRENT_LAUNCH_TRAJECTORY, launch_trajectory)

func _handle_spin(actor: PlayableCharacter, spin_speed: float, delta: float):
	return actor.mover.direction.rotated(Vector3.UP, atan2(actor.mover.direction.x, actor.mover.direction.z) + spin_speed * delta)

func _handle_launch_trajectory(_actor: PlayableCharacter, delta: float, launch_speed: float):
	var horizontal_input = Input.get_action_strength("launch_left") - Input.get_action_strength("launch_right")
	var vertical_input = Input.get_action_strength("launch_up") - Input.get_action_strength("launch_down")
	var input = Vector2(horizontal_input, vertical_input)
	
	launch_trajectory_horizontal_rotation += (input.x * delta * trajectory_horizontal_speed)
	launch_trajectory_vertical_rotation += (input.y * delta * trajectory_vertical_speed)
	launch_trajectory_vertical_rotation = clamp(
		launch_trajectory_vertical_rotation,
		deg_to_rad(min_vertical_trajectory_degrees),
		deg_to_rad(max_vertical_trajectory_degrees))
	
	launch_trajectory = Vector3.FORWARD.rotated(Vector3.RIGHT, launch_trajectory_vertical_rotation).normalized()
	launch_trajectory = launch_trajectory.rotated(Vector3.UP, launch_trajectory_horizontal_rotation).normalized()
	launch_trajectory *= launch_speed
func _update_launch_trajectory_indicator(launch_trajectory: Vector3, material: Material = null):
	launch_trajectory_indicator.set_trajectory(launch_trajectory)
	if material:
		launch_trajectory_indicator.set_material(material)

func _instantiate_burst_particles(parent: Node, scene: PackedScene):
	var burst = scene.instantiate()
	parent.add_child(burst)
	burst.get_node("%AnimationPlayer").play("self_destruct")

func _on_blunt_flow_state_update(delta: float, actor: PlayableCharacter, _blackboard: Blackboard):
	_handle_launch_trajectory(actor, delta, blunt_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, blunt_launch_parameters.get_launch_trajectory_indicator_material())
func _on_delta_flow_state_update(delta: float, actor: PlayableCharacter, _blackboard: Blackboard):
	_handle_launch_trajectory(actor, delta, delta_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, delta_launch_parameters.get_launch_trajectory_indicator_material())
func _on_epsilon_flow_state_update(delta: float, actor: PlayableCharacter, _blackboard: Blackboard):
	_handle_launch_trajectory(actor, delta, epsilon_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, epsilon_launch_parameters.get_launch_trajectory_indicator_material())
func _on_lambda_flow_state_update(delta: float, actor: PlayableCharacter, _blackboard: Blackboard):
	_handle_launch_trajectory(actor, delta, lambda_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, lambda_launch_parameters.get_launch_trajectory_indicator_material())

func _update_arial_actions(blackboard: Blackboard):
	if blackboard.get_value(ARIAL_ACTIONS_STRING) == null:
		blackboard.set_value(ARIAL_ACTIONS_STRING, [name])
		return
	blackboard.get_value(ARIAL_ACTIONS_STRING).append(name)