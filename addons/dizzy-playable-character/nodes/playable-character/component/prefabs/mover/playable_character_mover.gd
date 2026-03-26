class_name PlayableCharacterMover
extends PlayableCharacterComponent
## A [PlayableCharacter] component responsible for moving the [PlayableCharacter] via either manually
## or with root motion from an [AnimationTree].

const PLAYBACK_PATH: String = "parameters/playback"

# Root Motion Parameters

## If true, enables root motion instead of manual velocity editing.
@export var use_root_motion: bool = false
## if true, enables root rotation instead of manual rotation editing.
@export var use_root_rotation: bool = false

## The valid property path [StringName] to the parameter to start movement on the [Character]'s
## [AnimationTree].
@export var start_movement_parameter: StringName = &"parameters/conditions/start_move"
## The valid property path [StringName] to the parameter to start idling on the [Character]'s
## [AnimationTree].
@export var start_idle_parameter: StringName = &"parameters/conditions/idle"

# Components

## The [PlayableCharacterCharacterContainer] that this [PlayableCharacterMover] will use to
## reference the active character's attributes.
var character_container: PlayableCharacterCharacterContainer

# Gameplay Variables

var _direction: Vector3
var _vertical_velocity: Vector3
var _turn_speed: float = 10
var _root_velocity: Vector3 
var _root_rotation: Quaternion

# Animation

## The [AnimationTree] that belongs to the [member PlayableCharacterCharacterContainer.current_character].
## This node is the source of the root motion control.
var animation_tree: AnimationTree
## The [AnimationPlayer] that belongs to the [member PlayableCharacterCharacterContainer.current_character].
var animation_player: AnimationPlayer
var _animation_state

# Animation Parameters

var _can_move: bool

## Initializes this [PlayableCharacterMover] component for use, and sets the referenced character
## to the currently active character within [member PlayableCharacter.character_container].
##
## Takes [param playable_character] for the parent [PlayableCharacter].
func initialize(playable_character: PlayableCharacter):
	character_container = playable_character.character_container
	if not character_container.is_active:
		await character_container.initialized
	
	_setup_for_character(character_container.current_character)
	super(playable_character)

## Directly sets the velocity of the [member playable_character]. Does nothing if
## [member use_root_motion] is true.
func set_velocity(velocity: Vector3):
	if not is_active:
		return
	if use_root_motion:
		return
	playable_character.velocity = velocity
## Directly sets the direction of the [member character_container]. Does nothing if
## [member use_root_rotation] is true.
func set_direction(normalized_direction: Vector3):
	if not is_active:
		return
	if use_root_rotation:
		return
	_direction = normalized_direction

func _process(delta: float) -> void:
	if not is_active:
		return
	_root_velocity = _calculate_root_motion(delta)
	_root_rotation = _calculate_root_rotation()
	character_container.quaternion *= _root_rotation

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	_handle_update_animation_parameters()
	_update_character_container_rotation(delta)
	_update_playable_character_velocity()
	
	playable_character.move_and_slide()

func _setup_for_character(character: Character):
	if not is_active:
		return
	animation_tree = character.animation_tree
	animation_player = get_node(animation_tree.anim_player)
	_animation_state = animation_tree.get(PLAYBACK_PATH)

func _on_playable_character_character_container_current_character_changed(_old: Character, new: Character) -> void:
	if not is_active:
		return
	_setup_for_character(new)

func _handle_update_animation_parameters():
	if not is_active:
		return
	if not animation_tree:
		return
	animation_tree.set(start_movement_parameter, _can_move)
	animation_tree.set(start_idle_parameter, !_can_move)

	_can_move = !_direction.is_zero_approx()

func _calculate_root_motion(delta: float) -> Vector3:
	if not is_active:
		return Vector3.ZERO
	if not use_root_motion:
		return Vector3.ZERO
	var root_position = animation_tree.get_root_motion_position()
	var current_rotation = animation_tree.get_root_motion_rotation_accumulator().inverse() * character_container.quaternion
	var motion = current_rotation * root_position / delta

	return motion
func _calculate_root_rotation() -> Quaternion:
	if not is_active:
		return Quaternion.IDENTITY
	if not use_root_rotation:
		return Quaternion.IDENTITY
	return animation_tree.get_root_motion_rotation()

func _update_character_container_rotation(delta: float):
	if not is_active:
		return
	var rotation = character_container.rotation.y
	if not _direction.is_zero_approx():
		rotation = lerp_angle(character_container.rotation.y, atan2(_direction.x, _direction.z), _turn_speed * delta)
	character_container.rotation.y = rotation

func _update_playable_character_velocity():
	if not is_active:
		return
	if not use_root_motion:
		return
	playable_character.velocity = _root_velocity
