class_name DelaneyEntity extends CharacterBody3D

@export var _stats: EntityStats
@export var _status: EntityStatus

@export var _blackboard: Blackboard

@export var _terminal_velocity: float = 20.0

@onready var _camera: ThirdPersonCamera = %ThirdPersonCamera
@onready var _finite_state_machine: FiniteStateMachine = %FiniteStateMachine

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_blackboard.set_value("horizontal_velocity", Vector3.ZERO)
	_blackboard.set_value("vertical_velocity", Vector3.ZERO)
	
	_finite_state_machine.start()
	
	_finite_state_machine.state_changed.connect(func(state): print(_finite_state_machine.last_active_state.name + " -> " + state.name))

func _physics_process(delta: float) -> void:	
	move_and_slide()

func get_entity_stats() -> EntityStats:
	return _stats
func get_entity_status() -> EntityStatus:
	return _status

func get_blackboard() -> Blackboard:
	return _blackboard
	
func get_camera() -> ThirdPersonCamera:
	return _camera
func get_finite_state_machine() -> FiniteStateMachine:
	return _finite_state_machine
func get_terminal_velocity() -> float:
	return _terminal_velocity
