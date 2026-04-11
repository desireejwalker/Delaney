class_name PlayableCharacter
extends CharacterBody3D
## Node responsible for allowing the player to control [Character] nodes.

## Emitted when the light attack input action has been pressed.
# signal pressed_light_attack_input
## Emitted when the heavy attack input action has been pressed.
# signal pressed_heavy_attack_input

## Emitted when a [PlayableCharacterAction] is performed.
signal action_performed(action: PlayableCharacterAction)
## emitted when a [PlayableCharacterAction] is interrupted.
signal action_interrupted(action: PlayableCharacterAction)
## emitted when a [PlayableCharacterAction] has concluded.
signal action_concluded(action: PlayableCharacterAction)
## emitted when a [PlayableCharacterAction] is set as unavailable.
signal action_set_unavailable(action: PlayableCharacterAction)
## emitted when a [PlayableCharacterAction] is set as available.
signal action_set_available(action: PlayableCharacterAction)
## emitted when a [PlayableCharacterAction] is set as unavailable for a set period of time in
## seconds.
signal action_set_unavailable_duration(action: PlayableCharacterAction, duration_seconds: float)
## emitted when a [PlayableCharacterAction] is set as available for a set period of time in
## seconds.
signal action_set_available_duration(action: PlayableCharacterAction, duration_seconds: float)

## If true, this [PlayableCharacter] node will initialize itself on [method _ready].
@export var auto_initialize: bool = true

# Gameplay Attributes

## The current movement direction of this [PlayableCharacter].
# var direction: Vector3
## The movement direction of this [PlayableCharacter] relative to its front.
# var relative_direction: Vector3

# Components

## A [Dictionary] holding all [PlayableCharacterComponent] children of this [PlayableCharacter],
## stored by their [member Node.name]. This will be empty if [method PlayableCharacter.initialize]
## has not been called first.
var components: Dictionary[String, PlayableCharacterComponent]

## The [PlayableCharacterCharacterContainer] component that this [PlayableCharacter] references its
## [member PlayableCharacterCharacterContainer.current_character] from.
@onready var character_container: PlayableCharacterCharacterContainer = %PlayableCharacterCharacterContainer
## The [PlayableCharacterMover] component that is responsible for moving this [PlayableCharacter].
@onready var mover: PlayableCharacterMover = %PlayableCharacterMover
## The [PlayableCharacterCamera] component that the player will use on this [PlayableCharacter].
@onready var camera: PlayableCharacterCamera = %PlayableCharacterCamera
## The [PlayableCharacterStatusInterface] component that will provide access the [member Character.status]
## resource on the currently active character (via
## [member PlayableCharacterCharacterContainer.current_character]).
@onready var status_interface: PlayableCharacterStatusInterface = %PlayableCharacterStatusInterface
## The [PlayableCharacterHurtbox] component that will manage [Hitbox] detection for this
## [PlayableCharacter]
@onready var hurtbox: PlayableCharacterHurtbox = %PlayableCharacterHurtbox

func _ready() -> void:
	if auto_initialize:
		initialize()

func _process(delta) -> void:
	if Input.is_action_pressed("show_cursor"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func initialize() -> void:
	_setup_components()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# func _process(delta: float) -> void:
# 	var input_direction = Input.get_vector("strafe_left", "strafe_right", "forwards", "backwards")
# 	direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, camera.get_horizontal_rotation()).normalized()
# 	var dot = direction.dot(get_front_direction())
# 	var cross = direction.cross(get_front_direction())
# 	relative_direction = Vector3(cross.y, 0, dot).normalized()

func get_input_direction() -> Vector3:
	var direction = Vector3(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		0,
		Input.get_action_strength("backwards") - Input.get_action_strength("forwards"))
	direction = direction.rotated(Vector3.UP, camera.get_horizontal_rotation()).normalized()
	
	return direction

func emit_action_performed(action_type: PlayableCharacterAction, holding: bool):
	action_performed.emit(action_type, holding)
func emit_action_interrupted(action_type: PlayableCharacterAction):
	action_interrupted.emit(action_type)
func emit_action_concluded(action_type: PlayableCharacterAction):
	action_concluded.emit(action_type)
func emit_action_set_unavailable(action_type: PlayableCharacterAction):
	action_set_unavailable.emit(action_type)
func emit_action_set_available(action_type: PlayableCharacterAction):
	action_set_available.emit(action_type)
func emit_action_set_unavailable_duration(action_type: PlayableCharacterAction, duration_seconds: float):
	action_set_unavailable_duration.emit(action_type, duration_seconds)
func emit_action_set_available_duration(action_type: PlayableCharacterAction, duration_seconds: float):
	action_set_available_duration.emit(action_type, duration_seconds)

func _setup_components():
	var children = get_children()
	for child in children:
		if not child is PlayableCharacterComponent:
			continue
		
		var component = child as PlayableCharacterComponent
		components[component.name] = component
		component.initialize(self)

# func _on_died():
# 	pass

# func get_front_direction() -> Vector3:
# 	return Vector3.FORWARD.rotated(Vector3.UP, %PlayableCharacterCharacterContainer.global_rotation.y + PI).normalized()
# func get_back_direction() -> Vector3:
# 	return -get_front_direction().normalized()
# func get_left_direction() -> Vector3:
# 	return get_front_direction().rotated(Vector3.UP, PI/2).normalized()
# func get_right_direction() -> Vector3:
# 	return get_front_direction().rotated(Vector3.UP, -PI/2).normalized()
