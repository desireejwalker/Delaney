@tool
extends FSMState

const PAR_B_DELTA_FLOW_STATE_BURST_SCENE = preload("res://nodes/particle_systems/bursts/PAR_B_delta-flow-state-burst.tscn")
const PAR_B_EPSILON_FLOW_STATE_BURST_SCENE = preload("res://nodes/particle_systems/bursts/PAR_B_epsilon-flow-state-burst.tscn")
const PAR_B_LAMBDA_FLOW_STATE_BURST_SCENE = preload("res://nodes/particle_systems/bursts/PAR_B_lambda-flow-state-burst.tscn")

const ON_ADVANCE_TO_DELTA: String = "on_advance_to_delta"
const ON_ADVANCE_TO_EPSILON: String = "on_advance_to_epsilon"
const ON_ADVANCE_TO_LAMBDA: String = "on_advance_to_lambda"

const CURRENT_LAUNCH_TRAJECTORY: String = "current_launch_trajectory"

# Flow States

@export_category("Flow States")
@export_group("Delay")
@export var to_delta_state_delay: float = 1.0
@export var to_epsilon_state_delay: float = 1.5
@export var to_lambda_state_delay: float = 2.0

@export_group("Rotation Speed")
@export var blunt_rotation_speed: float = 400.0
@export var delta_rotation_speed: float = 800.0
@export var epsilon_rotation_speed: float = 1200.0
@export var lambda_rotation_speed: float = 1600.0

@export_group("Launch Parameters")
@export var blunt_launch_parameters: LaunchParameters
@export var delta_launch_parameters: LaunchParameters
@export var epsilon_launch_parameters: LaunchParameters
@export var lambda_launch_parameters: LaunchParameters

# Gameplay Parameters

@export_category("Gameplay Parameters")
@export var acceleration: float = 2
@export var speed: float = 10

var next_flow_state: FSMState
var rotation_speed: float
var current_launch_parameters: LaunchParameters
var launch_trajectory: Vector3 = Vector3.FORWARD

@onready var blunt_flow_state: FSMState = %Blunt
@onready var delta_flow_state: FSMState = %Delta
@onready var epsilon_flow_state: FSMState = %Epsilon
@onready var lambda_flow_state: FSMState = %Lambda

@onready var flow_states = [
	blunt_flow_state,
	delta_flow_state,
	epsilon_flow_state,
	lambda_flow_state
]

# Components

@onready var flow_state_finite_state_machine: PlayableCharacterFiniteStateMachine = %PlayableCharacterFlowStateFiniteStateMachine
@onready var launch_trajectory_indicator: LaunchTrajectoryIndicator = %LaunchTrajectoryIndicator
@onready var flow_state_change_timer: Timer = %FlowStateChangeTimer
# @onready var _hammer_animation_player: AnimationPlayer = %HammerAnimationPlayer

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var current_flow_state = flow_state_finite_state_machine.finite_state_machine.active_state
	if not _get_previous_flow_state(current_flow_state) == current_flow_state:
		current_flow_state = _get_previous_flow_state(current_flow_state)
		flow_state_finite_state_machine.finite_state_machine.change_state(current_flow_state)
	
	blunt_flow_state.on_update.connect(_on_blunt_flow_state_update)
	delta_flow_state.on_update.connect(_on_delta_flow_state_update)
	epsilon_flow_state.on_update.connect(_on_epsilon_flow_state_update)
	lambda_flow_state.on_update.connect(_on_lambda_flow_state_update)
	
	launch_trajectory_indicator.visible = true
	
	next_flow_state = _get_next_flow_state(current_flow_state)
	flow_state_change_timer.start(to_delta_state_delay)
	
	# hammer_animation_player.play("hammer_launching")

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	# if not Input.is_action_pressed("spin"):
	# 	var launched = _handle_launch(actor, blackboard)
	# 	return
	
	# if not actor.is_on_floor():
	# 	get_parent().fire_event("hammer_launching/on_start_arial_hammer_launching")
	# 	return
	
	var input_direction = actor.get_input_direction()
	var velocity = _handle_movement(actor, input_direction, delta)
	var direction = _handle_spin(actor, rotation_speed, delta)

	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity)

	_handle_flow_states(actor, blackboard)

# Executes before the state is exited.
func _on_exit(_actor: Node, blackboard: Blackboard) -> void:
	blunt_flow_state.on_update.disconnect(_on_blunt_flow_state_update)
	delta_flow_state.on_update.disconnect(_on_delta_flow_state_update)
	epsilon_flow_state.on_update.disconnect(_on_epsilon_flow_state_update)
	lambda_flow_state.on_update.disconnect(_on_lambda_flow_state_update)
	
	launch_trajectory_indicator.visible = false
	
	blackboard.set_value(CURRENT_LAUNCH_TRAJECTORY, launch_trajectory)

func _handle_movement(actor: PlayableCharacter, direction: Vector3, delta: float) -> Vector3:
	if direction.is_zero_approx():
		return actor.velocity.move_toward(Vector3.ZERO, acceleration * delta)
	return actor.velocity.move_toward(direction * speed, acceleration * delta)
# handle advancing to higher launch levels (up to 3)
func _handle_flow_states(actor: PlayableCharacter, blackboard: Blackboard):
	match next_flow_state:
		delta_flow_state:
			if not flow_state_change_timer.is_stopped():
				rotation_speed = blunt_rotation_speed
				return
			 
			flow_state_finite_state_machine.finite_state_machine.fire_event(ON_ADVANCE_TO_DELTA)
			next_flow_state = _get_next_flow_state(next_flow_state)
			
			rotation_speed = delta_rotation_speed

			_instantiate_burst_particles(actor, PAR_B_DELTA_FLOW_STATE_BURST_SCENE)
			flow_state_change_timer.start(to_epsilon_state_delay)
		epsilon_flow_state:
			if not flow_state_change_timer.is_stopped():
				rotation_speed = delta_rotation_speed
				return
			
			flow_state_finite_state_machine.finite_state_machine.fire_event(ON_ADVANCE_TO_EPSILON)
			next_flow_state = _get_next_flow_state(next_flow_state)
			
			rotation_speed = epsilon_rotation_speed

			_instantiate_burst_particles(actor,PAR_B_EPSILON_FLOW_STATE_BURST_SCENE)
			flow_state_change_timer.start(to_lambda_state_delay)
		lambda_flow_state:
			if not flow_state_change_timer.is_stopped():
				rotation_speed = epsilon_rotation_speed
				return
			
			flow_state_finite_state_machine.finite_state_machine.fire_event(ON_ADVANCE_TO_LAMBDA)
			next_flow_state = null
			
			rotation_speed = lambda_rotation_speed

			_instantiate_burst_particles(actor,PAR_B_LAMBDA_FLOW_STATE_BURST_SCENE)
func _handle_spin(actor: PlayableCharacter, speed: float, delta: float):
	return actor.mover.direction.rotated(Vector3.UP, atan2(actor.mover.direction.x, actor.mover.direction.z) + speed * delta)

func _handle_launch_trajectory(actor: PlayableCharacter, input_direction: Vector3, launch_speed: float):
	var direction: Vector3 = input_direction
	if direction.is_zero_approx():
		direction = Vector3.FORWARD.rotated(Vector3.UP, actor.camera.get_horizontal_rotation())
	launch_trajectory = direction * launch_speed
func _update_launch_trajectory_indicator(launch_trajectory: Vector3, material: Material = null):
	launch_trajectory_indicator.set_trajectory(launch_trajectory)
	if material:
		launch_trajectory_indicator.set_material(material)

func _get_next_flow_state(current_flow_state: FSMState):
	var current_flow_state_index = flow_states.find(current_flow_state)
	var next_flow_state_index = current_flow_state_index + 1
	if next_flow_state_index >= flow_states.size():
		next_flow_state_index = current_flow_state_index
	
	return flow_states[next_flow_state_index]
func _get_previous_flow_state(current_flow_state: FSMState):
	var current_flow_state_index = flow_states.find(current_flow_state)
	var next_flow_state_index = current_flow_state_index - 1
	if next_flow_state_index < 0:
		next_flow_state_index = current_flow_state_index
	
	return flow_states[next_flow_state_index]

func _instantiate_burst_particles(parent: Node, scene: PackedScene):
	var burst = scene.instantiate()
	parent.add_child(burst)
	burst.get_node("%AnimationPlayer").play("self_destruct")

func _on_blunt_flow_state_update(_delta: float, actor: PlayableCharacter, blackboard: Blackboard):
	_handle_launch_trajectory(actor, actor.get_input_direction(), blunt_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, blunt_launch_parameters.get_launch_trajectory_indicator_material())
func _on_delta_flow_state_update(_delta: float, actor: PlayableCharacter, blackboard: Blackboard):
	_handle_launch_trajectory(actor, actor.get_input_direction(), delta_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, delta_launch_parameters.get_launch_trajectory_indicator_material())
func _on_epsilon_flow_state_update(_delta: float, actor: PlayableCharacter, blackboard: Blackboard):
	_handle_launch_trajectory(actor, actor.get_input_direction(), epsilon_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, epsilon_launch_parameters.get_launch_trajectory_indicator_material())
func _on_lambda_flow_state_update(_delta: float, actor: PlayableCharacter, blackboard: Blackboard):
	_handle_launch_trajectory(actor, actor.get_input_direction(), lambda_launch_parameters.get_speed())
	_update_launch_trajectory_indicator(launch_trajectory, lambda_launch_parameters.get_launch_trajectory_indicator_material())
