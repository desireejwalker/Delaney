class_name RendererMarker
extends Node
## A node that marks its parent for copying to another [Renderer].

## If true, this [PlayableCharacter] node will initialize itself on [method _ready].
@export var auto_initialize: bool = true

# Renderer

## The name of the [Renderer] node that the [member parent] will be copied to.
@export var renderer_name: StringName

# Component

## The parent node that will be copied to the given [Renderer], if it exists.
var parent: Node3D
var parent_properties: Array[Dictionary]
## The parent of the [member parent]. If the [member parent] is returned to its original
## [Renderer], it will be reparented to this node. Otherwise, this will become the parent of the
## [member world_origin].
# var grandparent: Node
## The node that this node will copy [member parent]'s properties to.
var copy: Node3D
## The [Renderer] that the [member copy] will be placed under.
var renderer: Renderer
## The ancestor [GameRenderer] node.
@onready var game_renderer: GameRenderer = find_parent("GameRenderer")

func _ready() -> void:
	if auto_initialize:
		initialize()

func initialize() -> void:
	parent = get_parent()
	if parent.has_meta("copied") and parent.get_meta("copied"):
		queue_free()
		return
	
	if not game_renderer.is_active:
		await game_renderer.initialized
	if not game_renderer.renderers.has(renderer_name):
		printerr("Ancestor GameRenderer has no Renderer by name "+renderer_name+"!")
		print(game_renderer.renderers)
		return
	renderer = game_renderer.renderers[renderer_name]

	parent_properties = parent.get_property_list()
	# if not parent.is_node_ready():
	# 	await parent.ready
	# grandparent = parent.get_parent()
	copy = parent.duplicate()
	copy.set_meta("copied", true)
	renderer.sub_viewport.add_child(copy)
	parent.visible = false

func _process(delta: float) -> void:
	_copy_properties()

func _copy_properties():
	if copy == null:
		return
	if parent_properties == null or parent_properties.is_empty():
		return
	for property in parent_properties:
		var name = property["name"]
		if name == "owner":
			continue
		if name == "visible":
			continue
		var value = parent.get(name)
		copy.set(name, value)
