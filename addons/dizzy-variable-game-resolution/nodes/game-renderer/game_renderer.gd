@tool
class_name GameRenderer
extends Control
## Node responsible for combining [Renderer] nodes.

signal initialized

# Input Actions

@export_group("Input Actions")
## The name of the input action that will show the cursor.
@export var show_cursor_input_action: StringName = &"show_cursor"

## If true, this [PlayableCharacter] node will initialize itself on [method _ready].
@export var auto_initialize: bool = true

# Components

## The [Renderer] responsible for rendering the main game scene (usually the scene with the player
## controller). All [RendererCameras] under this [GameRenderer] node will copy the properties of
## this [Renderer]'s current camera (see [member Camera3D.current] and 
## [method Camera2D.is_current]).
@export var main_renderer: Renderer
## A [Dictionary] holding all [Renderer] children of this [GameRenderer] by their name as a key.
## This will be empty if [method PlayableCharacter.initialize] has not been called first.
var renderers: Dictionary[StringName,Renderer]

## If true, this [GameRenderer] is active and will process.
var is_active: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if auto_initialize:
		initialize()

func _process(delta) -> void:
	_handle_show_cursor()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if main_renderer == null:
		warnings.append("This GameRenderer has no main Renderer set. Please provide a main Renderer node.")
	return warnings

func initialize() -> void:
	_setup_renderers()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_active = true
	initialized.emit()

func _setup_renderers():
	var children = get_children()
	for child in children:
		if not child is Renderer:
			continue
		
		var renderer = child as Renderer
		renderers[renderer.name] = renderer
		renderer.initialize(self)

func _handle_show_cursor():
	if Engine.is_editor_hint():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	if Input.is_action_pressed(show_cursor_input_action):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
