@tool
extends FSMState

@export var acceleration: float = 5
@export var speed: float = 10
@export var boost_force: float = 1.6
@export var max_horizontal_velocity: float = 20.0
@export var speed_without_input: float = 0.2

@onready var slide_limit_timer: Timer = %SlideLimitTimer

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	# give delaney a boost of speed when she starts sliding
	# if she's not landing to keep from gaining exponential speed
	# via holding W, Shift, C and Spacebar.
	if not get_parent().last_active_state == %Landing:
		var velocity = _handle_slide_force(actor.velocity)
		actor.velocity = velocity
	#if not get_parent().last_active_state == %LongJumping:
		slide_limit_timer.start()

# Executes every _process call, if the state is active.
func _on_update(delta: float, actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter
	
	var input_direction = actor.get_input_direction()
	var velocity = _handle_sliding(actor.velocity, input_direction, delta)
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity)

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _handle_slide_force(current_velocity: Vector3) -> Vector3:
	var velocity = Vector3(
		current_velocity.x * boost_force,
		0,
		current_velocity.z * boost_force
	).limit_length(max_horizontal_velocity)
	return velocity

func _handle_sliding(current_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	var velocity = Vector3.ZERO
	if direction.is_zero_approx():
		velocity = current_velocity.move_toward((current_velocity.limit_length(speed_without_input) * speed), acceleration * delta)
	else:
		velocity = current_velocity.move_toward((direction * speed), acceleration * delta)
	
	return velocity