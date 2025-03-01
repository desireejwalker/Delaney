@tool
extends FSMState

@export var _launch_shape_3D: Shape3D

var _saved_collider_offset: Vector3
var _saved_shape_3D: Shape3D
var _launch_parameters: LaunchParameters
var _trail_instance: Node3D

@onready var _collider: CollisionShape3D = %CollisionShape3D
@onready var _mesh: MeshInstance3D = %MeshInstance3D
@onready var _hammer: Node3D = %Hammer
@onready var _launch_timer: Timer = %LaunchTimer

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	
	_saved_shape_3D = _collider.shape
	_saved_collider_offset = _collider.position
	_collider.shape = _launch_shape_3D
	_collider.position = Vector3(0, 1, 0)
	
	_mesh.visible = false
	_hammer.visible = false
	
	_launch_parameters = blackboard.get_value("current_launch_parameters")
	_trail_instance = _launch_parameters.get_trail_particle_system().instantiate()
	actor.add_child(_trail_instance)
	
	var trajectory = blackboard.get_value("current_launch_trajectory")
	actor.velocity = trajectory
	
	if _launch_parameters.does_ricochet():
		actor.set_do_move_and_slide(false)
	
	_launch_timer.timeout.connect(_on_launch_timer_timeout)
	_launch_timer.start(_launch_parameters.get_duration_seconds())

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	var collision = actor.get_last_slide_collision()
	if _launch_parameters.does_ricochet():
		collision = actor.move_and_collide(actor.velocity * delta)
	var did_ricochet = _handle_ricochet(actor, collision)

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: Blackboard) -> void:
	actor = actor as DelaneyEntity
	
	actor.set_do_move_and_slide(true)
	
	_collider.shape = _saved_shape_3D
	_saved_shape_3D = null
	_collider.position = _saved_collider_offset
	_saved_collider_offset = Vector3.ZERO
	
	_mesh.visible = true
	_hammer.visible = true
	
	blackboard.set_value("current_launch_trajectory", null)
	
	_trail_instance.get_node("%AnimationPlayer").play("self_destruct")

func _handle_ricochet(actor: Node, collision: KinematicCollision3D) -> bool:
	if not collision:
		return false
	if not _launch_parameters.does_ricochet():
		get_parent().fire_event("launching/on_start_falling")
		return false
	
	actor = actor as DelaneyEntity
	
	actor.velocity = actor.velocity.bounce(collision.get_normal())
	return true

func _on_launch_timer_timeout():
	get_parent().fire_event("launching/on_start_falling")
