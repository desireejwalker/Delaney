@tool
class_name Renderer
extends Control
## Node responsible for rendering a [PackedScene] at a set resolution.

signal initialized

# Element

@export_group("Element")
## The [PackedScene] to be instantiated as a child of [member sub_viewport].
@export var element: PackedScene:
	set(value):
		element = value
		if element == null:
			element_instance.queue_free()
			return
		_instantiate_element_when_ready()
## If true, the [member element] is instantiated when [method _ready] is called.
@export var instantiate_element_on_ready: bool = true

# Render Parameters

@export_group("Render Parameters")
## The resolution (width, height) that the UI will be rendered at.
@export var resolution: Vector2i = Vector2i(1920, 1080):
	set(value):
		resolution = value
		_set_when_ready("%SubViewport", &"size", resolution)
# ## See [member SubViewportContainer.stretch_srink].
# @export var stretch_shrink: int = 1:
# 	set(value):
# 		stretch_shrink = value
# 		_set_when_ready("%SubViewportContainer", &"stretch_shrink", stretch_shrink)
## See [member SubViewportContainer.mouse_target].
@export var mouse_target: bool = false:
	set(value):
		mouse_target = value
		_set_when_ready("%SubViewport", &"mouse_target", mouse_target)

# Input

@export_group("Input")
## If true, any input events are pushed through to the child [SubViewport].
@export var push_input: bool = true

# # SubViewport Properties

# @export_category("SubViewport")
# ## See [member SubViewport.render_target_clear_mode].
# @export var render_target_clear_mode: SubViewport.ClearMode = SubViewport.ClearMode.CLEAR_MODE_ALWAYS
# ## See [member SubViewport.render_target_update_mode].
# @export var render_target_update_mode: SubViewport.UpdateMode = SubViewport.UpdateMode.UPDATE_ALWAYS

# Viewport

@export_category("Viewport")
## See [member Viewport.disable_3d].
@export var disable_3d: bool = false
## See [member Viewport.use_xr].
@export var use_xr: bool = false
## See [member Viewport.own_world_3d].
@export var own_world_3d: bool = false
## See [member Viewport.world_3d].
@export var world_3d: World3D
## See [member Viewport.transparent_bg].
@export var transparent_bg: bool = false
## See [member Viewport.snap_2d_transforms_to_pixel].
@export var snap_2d_transforms_to_pixel: bool = false
## See [member Viewport.snap_2d_vertices_to_pixel].
@export var snap_2d_vertices_to_pixel: bool = false

@export_group("Rendering")
## See [member Viewport.msaa_2d].
@export var msaa_2d: Viewport.MSAA = 0
## See [member Viewport.msaa_3d].
@export var msaa_3d: Viewport.MSAA = 0
## See [member Viewport.screen_space_aa].
@export var screen_space_aa: Viewport.ScreenSpaceAA = 0
## See [member Viewport.use_taa].
@export var use_taa: bool = false
## See [member Viewport.use_debanding].
@export var use_debanding: bool = false
## See [member Viewport.use_occlusion_culling].
@export var use_occlusion_culling: bool = false
## See [member Viewport.mesh_lod_threshold].
@export var mesh_lod_threshold: float = 0
## See [member Viewport.debug_draw].
@export var debug_draw: Viewport.DebugDraw = 0
## See [member Viewport.use_hdr_2d].
@export var use_hdr_2d: bool = false

@export_group("Scaling 3D")
## See [member Viewport.scaling_3d_mode].
@export var scaling_3d_mode: Viewport.Scaling3DMode = 0
## See [member Viewport.scaling_3d_scale].
@export var scaling_3d_scale: float = 1
## See [member Viewport.texture_mipmap_bias].
@export var texture_mipmap_bias: float =  0
## See [member Viewport.anisotropic_filtering_level].
@export var anisotropic_filtering_level: Viewport.AnisotropicFiltering = 2
## See [member Viewport.fsr_sharpness].
@export var fsr_sharpness: float =  0.2

@export_group("Variable Rate Shading")
## See [member Viewport.vrs_mode].
@export var vrs_mode: Viewport.VRSMode = 0
## See [member Viewport.vrs_update_mode].
@export var vrs_update_mode: Viewport.VRSUpdateMode = 1
## See [member Viewport.vrs_texture].
@export var vrs_texture: Texture2D

@export_group("Canvas Items")
## See [member Viewport.canvas_item_default_texture_filter].
@export var canvas_item_default_texture_filter: Viewport.DefaultCanvasItemTextureFilter = 1
## See [member Viewport.canvas_item_default_texture_repeat].
@export var canvas_item_default_texture_repeat: Viewport.DefaultCanvasItemTextureRepeat = 0

@export_group("Audio Listener")
## See [member Viewport.audio_listener_enable_2d].
@export var audio_listener_enable_2d: bool = false
## See [member Viewport.audio_listener_enable_3d].
@export var audio_listener_enable_3d: bool = false

@export_group("Physics")
## See [member Viewport.physics_object_picking].
@export var physics_object_picking: bool = false
## See [member Viewport.physics_object_picking_sort].
@export var physics_object_picking_sort: bool = false
## See [member Viewport.physics_object_picking_first_only].
@export var physics_object_picking_first_only: bool = false

@export_group("GUI")
## See [member Viewport.gui_disable_input].
@export var gui_disable_input: bool = false
## See [member Viewport.gui_snap_controls_to_pixels].
@export var gui_snap_controls_to_pixels: bool = true
## See [member Viewport.gui_embed_subwindows].
@export var gui_embed_subwindows: bool = false
## See [member Viewport.gui_drag_threshold].
@export var gui_drag_threshold: int = 10

@export_group("SDF")
## See [member Viewport.sdf_oversize].
@export var sdf_oversize: Viewport.SDFOversize = 1
## See [member Viewport.sdf_scale].
@export var sdf_scale: Viewport.SDFScale = 1

@export_group("Position Shadow Atlas")
## See [member Viewport.canvas_cull_mask].
@export_flags_2d_render var canvas_cull_mask: int = 0xFFFFFFFF
## See [member Viewport.oversampling].
@export var oversampling: bool = true
## See [member Viewport.oversampling_override].
@export var oversampling_override: float = 0

## If true, this [Renderer] is active and will process.
var is_active: bool = false

# Element

## The instance of the [member element] currently in use.
var element_instance

# Components

var game_renderer: GameRenderer

# ## The [SubViewportContainer] node that contains the [member sub_viewport].
# @onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer
## The [TextureRect] node that will display the [member sub_viewport]'s render result.
@onready var sub_viewport_texture_rect = %SubViewportTextureRect
## The [SubViewport] node that renders the UI nodes at the resolution [resolution].
@onready var sub_viewport: SubViewport = %SubViewport

func initialize(game_renderer: GameRenderer):
	self.game_renderer = game_renderer
	is_active = true
	initialized.emit()

func _process(delta: float) -> void:
	_update_sub_viewport_properties()

func _input(event: InputEvent) -> void:
	_handle_push_input(event)

func _instantiate_element_when_ready():
	if not is_node_ready():
		await ready
		element_instance = element.instantiate()
		sub_viewport.add_child(element_instance)
	else:
		if not Engine.is_editor_hint() and not instantiate_element_on_ready:
			return
		element_instance = element.instantiate()
		sub_viewport.add_child(element_instance)
		
func _set_when_ready(node_path: NodePath, property_name: StringName, value: Variant):
	if not is_node_ready():
		await ready
		get_node(node_path).set(property_name, value)
	else :
		get_node(node_path).set(property_name, value)

func _update_sub_viewport_properties():
	if not is_active:
		return
	# sub_viewport.render_target_clear_mode = render_target_clear_mode
	# sub_viewport.render_target_update_mode = render_target_update_mode

	sub_viewport.disable_3d = disable_3d
	sub_viewport.use_xr = use_xr
	sub_viewport.own_world_3d = own_world_3d
	if sub_viewport.world_3d != world_3d:
		sub_viewport.world_3d = world_3d
	sub_viewport.transparent_bg = transparent_bg
	sub_viewport.snap_2d_transforms_to_pixel = snap_2d_transforms_to_pixel
	sub_viewport.snap_2d_vertices_to_pixel = snap_2d_vertices_to_pixel
	sub_viewport.msaa_2d = msaa_2d
	sub_viewport.msaa_3d = msaa_3d
	sub_viewport.screen_space_aa = screen_space_aa
	sub_viewport.use_taa = use_taa
	sub_viewport.use_debanding = use_debanding
	sub_viewport.use_occlusion_culling = use_occlusion_culling
	sub_viewport.mesh_lod_threshold = mesh_lod_threshold
	sub_viewport.debug_draw = debug_draw
	sub_viewport.use_hdr_2d = use_hdr_2d
	sub_viewport.scaling_3d_mode = scaling_3d_mode
	sub_viewport.scaling_3d_scale = scaling_3d_scale
	sub_viewport.texture_mipmap_bias = texture_mipmap_bias
	sub_viewport.anisotropic_filtering_level = anisotropic_filtering_level
	sub_viewport.fsr_sharpness = fsr_sharpness
	sub_viewport.vrs_mode = vrs_mode
	sub_viewport.vrs_update_mode = vrs_update_mode
	sub_viewport.vrs_texture = vrs_texture
	sub_viewport.canvas_item_default_texture_filter = canvas_item_default_texture_filter
	sub_viewport.canvas_item_default_texture_repeat = canvas_item_default_texture_repeat
	sub_viewport.audio_listener_enable_2d = audio_listener_enable_2d
	sub_viewport.audio_listener_enable_3d = audio_listener_enable_3d
	sub_viewport.physics_object_picking = physics_object_picking
	sub_viewport.physics_object_picking_sort = physics_object_picking_sort
	sub_viewport.physics_object_picking_first_only = physics_object_picking_first_only
	sub_viewport.gui_disable_input = gui_disable_input
	sub_viewport.gui_snap_controls_to_pixels = gui_snap_controls_to_pixels
	sub_viewport.gui_embed_subwindows = gui_embed_subwindows
	sub_viewport.gui_drag_threshold = gui_drag_threshold
	sub_viewport.sdf_oversize = sdf_oversize
	sub_viewport.sdf_scale = sdf_scale
	sub_viewport.canvas_cull_mask = canvas_cull_mask
	sub_viewport.oversampling = oversampling
	sub_viewport.oversampling_override = oversampling_override

func _handle_push_input(event: InputEvent):
	if not push_input:
		return
	sub_viewport.push_input(event, true)
