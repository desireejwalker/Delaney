class_name PlayableCharacterController
extends PlayableCharacterComponent
## A [PlayableCharacter] component responsible for applying player input to a [PlayableCharacter].
## [br][br]

# Input Actions

@export var move_forwards_input_action: StringName = &"forwards"
@export var move_backwards_input_action: StringName = &"backwards"
@export var strafe_left_input_action: StringName = &"strafe_left"
@export var strafe_right_input_action: StringName = &"strafe_right"

# Gameplay Parameters

## How fast the [PlayableCharacter] will reach [member speed].
@export var acceleration: float = 25
## The [PlayableCharacter]'s movement speed.
@export var speed: float = 10

var input_direction: Vector3

# Components

## The [PlayableCharacterMover] that this [PlayableCharacterController] will interact with to move
## The [PlayableCharacter].
var mover: PlayableCharacterMover
## The [PlayableCharacterCamera] that this [PlayableCharacterController] will use to determine the
## direction of movement for the [PlayableCharacter].
var camera: PlayableCharacterCamera

func initialize(playable_character: PlayableCharacter):
	mover = playable_character.mover
	camera = playable_character.camera
	if not mover.is_active:
		await mover.initialized
	if not camera.is_active:
		await camera.initialized

	super(playable_character)

func _unhandled_input(event: InputEvent) -> void:
	input_direction = _get_input_direction()

func _physics_process(delta: float) -> void:
	var velocity = _handle_walking(playable_character.velocity, delta)
	mover.set_velocity(velocity)
	mover.set_direction(velocity.normalized())

func _get_input_direction() -> Vector3:
	var direction = Vector3(
		Input.get_action_strength(strafe_right_input_action) - Input.get_action_strength(strafe_left_input_action),
		0,
		Input.get_action_strength(move_backwards_input_action) - Input.get_action_strength(move_forwards_input_action))
	direction = direction.rotated(Vector3.UP, camera.get_horizontal_rotation()).normalized()
	
	return direction

func _handle_walking(current_velocity: Vector3, delta: float) -> Vector3:
	return current_velocity.move_toward(input_direction * speed, acceleration * delta)