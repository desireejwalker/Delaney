@tool
extends FSMState

# Gameplay Parameters

@export var speed_retained_percentage: float = 0.5

# Components

@onready var skid_timer: Timer = %SkidTimer
@onready var skid_cooldown_timer: Timer = %SkidCooldownTimer

# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: Blackboard) -> void:
	actor = actor as PlayableCharacter

	var velocity = _handle_skidding(actor.velocity)
	actor.mover.set_velocity(velocity)
	actor.mover.set_direction(velocity.normalized())
	
	skid_timer.timeout.connect(_on_skid_timer_timeout.bind(actor))
	skid_timer.start()

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	skid_timer.timeout.disconnect(_on_skid_timer_timeout)

func _handle_skidding(current_velocity: Vector3) -> Vector3:
	var velocity = Vector3(
		current_velocity.x * speed_retained_percentage,
		0,
		current_velocity.z * speed_retained_percentage)
	
	return velocity

func _on_skid_timer_timeout(actor: PlayableCharacter):
	actor.mover.set_velocity(Vector3.ZERO)
	skid_cooldown_timer.start()
