class_name DelaneyEntity extends CharacterBody3D

enum FlowState
{
	STATE_BLUNT,
	STATE_DELTA,
	STATE_EPSILON,
	STATE_LAMBDA
}

@export var _stats: EntityStats
@export var _status: EntityStatus

@export var _blackboard: Blackboard

@export var _terminal_velocity: float = 20.0

var _do_move_and_slide: bool = true

@onready var _camera: ThirdPersonCamera = %ThirdPersonCamera
@onready var _movement_finite_state_machine: FiniteStateMachine = %MovementFiniteStateMachine
@onready var _flow_state_finite_state_machine: FiniteStateMachine = $FlowStateFiniteStateMachine

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_blackboard.set_value("horizontal_velocity", Vector3.ZERO)
	_blackboard.set_value("vertical_velocity", Vector3.ZERO)
	
	_blackboard.set_value("flow_state", FlowState.STATE_BLUNT)
	
	_movement_finite_state_machine.start()
	_flow_state_finite_state_machine.start()
	
	_movement_finite_state_machine.state_changed.connect(func(state): print(_movement_finite_state_machine.last_active_state.name + " -> " + state.name))
	_flow_state_finite_state_machine.state_changed.connect(func(state): print(_flow_state_finite_state_machine.last_active_state.name + " -> " + state.name))

func _physics_process(delta: float) -> void:
	if _do_move_and_slide:
		move_and_slide()

func get_entity_stats() -> EntityStats:
	return _stats
func get_entity_status() -> EntityStatus:
	return _status

func get_blackboard() -> Blackboard:
	return _blackboard
	
func get_camera() -> ThirdPersonCamera:
	return _camera
func get_movement_finite_state_machine() -> FiniteStateMachine:
	return _movement_finite_state_machine
func get_flow_state_finite_state_machine() -> FiniteStateMachine:
	return _flow_state_finite_state_machine
func get_terminal_velocity() -> float:
	return _terminal_velocity
