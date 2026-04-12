# @tool
class_name RendererCamera
extends Camera3D
## A camera node for [Renderer]s that render 3D objects. Will copy the properties applied to the
## current camera of the [member GameRenderer.main_renderer]. Should be the child of a
## [SubViewport] node.

# Components

## The parent [Renderer] node.
@export var renderer: Renderer
## The current camera of the [member GameRenderer.main_renderer]
var main_renderer_camera: Camera3D

func _ready() -> void:
	current = true
	main_renderer_camera = await _get_main_renderer_camera()

func _process(_delta: float) -> void:
	_copy_main_renderer_camera_properties()

func _get_main_renderer_camera() -> Camera3D:
	if not renderer.is_active:
		await renderer.initialized
	if not renderer.game_renderer.is_active:
		await renderer.game_renderer.initialized
	
	return renderer.game_renderer.main_renderer.sub_viewport.get_camera_3d()

func _copy_main_renderer_camera_properties():
	if not is_instance_valid(main_renderer_camera):
		return
	if not main_renderer_camera.current:
		return
	
	self.global_position = main_renderer_camera.global_position
	self.global_rotation = main_renderer_camera.global_rotation
	self.scale = main_renderer_camera.scale

	if not self.environment == main_renderer_camera.environment:
		self.environment = main_renderer_camera.environment
	if not self.attributes == main_renderer_camera.attributes:
		self.attributes = main_renderer_camera.attributes
	if not self.compositor == main_renderer_camera.compositor:
		self.compositor = main_renderer_camera.compositor
	
	self.projection = main_renderer_camera.projection

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not (get_parent() is Renderer):
		warnings.append("This RendererCamera must be the child of a Renderer node.")
	return warnings
