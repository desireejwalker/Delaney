@tool
class_name PlayableCharacterCamera
extends PlayableCharacterComponent
## A [PlayableCharacter] component responsible for providing a player controlled camera to a
## [PlayableCharacter]. [br][br]
## Code based on Jean KOUSSAWO's Third Person Camera addon.

# Camera Transform Parameters

## The distance from the pivot point.
@export var distance_from_pivot: float = 10.0:
	set(value) :
		distance_from_pivot = value
		_set_when_ready("%CameraSpringArm", &"spring_length", distance_from_pivot)
## The offset of the pivot point from relative (0, 0).
@export var pivot_offset: Vector2 = Vector2.ZERO
## The initial vertical angle of the camera in degrees.
@export_range(-90.0, 90.0) var initial_dive_angle_deg: float = -20.0:
	set(value) :
		initial_dive_angle_deg = clampf(value, tilt_lower_limit_deg, tilt_upper_limit_deg)
## The maximum degrees the camera can tilt upwards.
@export_range(-90.0, 90.0) var tilt_upper_limit_deg: float = 60.0
## The minimum degrees the camera can tilt downwards.
@export_range(-90.0, 90.0) var tilt_lower_limit_deg: float = -60.0
## The sensitivity for camera vertical tilt.
@export_range(1.0, 1000.0) var tilt_sensitivity: float = 10.0
## The sensitivity for camera horizontal rotation.
@export_range(1.0, 1000.0) var horizontal_rotation_sensitivity: float = 10.0
## The speed at which the camera moves towards its target position. Lower values smoothen motion,
## while higher values stiffen camera movement.
@export_range(0.1, 1) var camera_speed: float = 0.1
## If true, this is the active camera used by the parent viewport.
@export var current: bool = false:
	set(value) :
		current = value
		_set_when_ready("%WorldCamera", &"current", value)

# Mouse Controls

@export_group("Mouse Controls")
## if true, this camera is controlled by mouse input. [br][br]
@export var mouse_follow: bool = true
## The mouse control sensitivity on the x axis.
@export_range(0, 100) var mouse_x_sensitivity: float = 1
## The mouse control sensitivity on the y axis.
@export_range(0, 100) var mouse_y_sensitivity: float = 1
## The speed at which scrolling the mouse wheel will zoom the camera in and out.
@export var zoom_speed: float = 0.5
## The maximum zoom (furthest away) of the camera.
@export var max_zoom: float
## The minimum zoom (closest) of the camera.
@export var min_zoom: float

# Input Actions

@export_group("Input Actions")
## The name of the input action that will zoom the camera in.
@export var zoom_in_input_action: StringName = &"zoom_camera_in"
## The name of the input action that will zoom the camera out.
@export var zoom_out_input_action: StringName = &"zoom_camera_out"
## The name of the input action that will tilt the camera up.
@export var tilt_up_input_action: StringName = &"tilt_camera_up"
## The name of the input action that will tilt the camera down.
@export var tilt_down_input_action: StringName = &"tilt_camera_down"
## The name of the input action that will rotate the camera right.
@export var rotate_camera_right_input_action: StringName = &"rotate_camera_right"
## The name of the input action that will rotate the camera left.
@export var rotate_camera_left_input_action: StringName = &"rotate_camera_left"

# SpringArm3D Properties

@export_category("SpringArm3D")
## See [member SpringArm3D.collision_mask].
@export_flags_3d_render var spring_arm_collision_mask: int = 1:
	set(value) :
		spring_arm_collision_mask = value
		_set_when_ready("%CameraSpringArm", &"collision_mask", value)
## See [member SpringArm3D.margin].
@export_range(0.0, 100.0, 0.01, "or_greater", "or_less", "hide_slider", "suffix:m") var spring_arm_margin: float = 0.01:
	set(value):
		spring_arm_margin = value
		_set_when_ready("%CameraSpringArm", &"margin", spring_arm_margin)

# Camera3D Properties

@export_category("Camera3D")
## See [member Camera3D.keep_aspect].
@export var keep_aspect: Camera3D.KeepAspect = Camera3D.KEEP_HEIGHT
## See [member Camera3D.cull_mask].
@export_flags_3d_render var cull_mask: int = 1048575
## See [member Camera3D.environment].
@export var environment: Environment
## See [member Camera3D.attributes].
@export var attributes: CameraAttributes
## See [member Camera3D.doppler_tracking].
@export var doppler_tracking: Camera3D.DopplerTracking = Camera3D.DOPPLER_TRACKING_DISABLED
## See [member Camera3D.projection].
@export var projection: Camera3D.ProjectionType = Camera3D.PROJECTION_PERSPECTIVE
## See [member Camera3D.fov].
@export_range(1.0, 179.0, 0.1, "suffix:°") var fov: float = 75
## See [member Camera3D.near].
@export var near: float = 0.05
## See [member Camera3D.far].
@export var far: float = 4000.0

# Camera Gameplay Parameters

## The current camera tilt in degrees.
var camera_tilt_deg: float = 0
## The current camera horizontal rotation in degrees.
var camera_horizontal_rotation_deg: float = 0
## If false, this [PlayableCharacterCamera] node is unaffected by player input.
var enable_input: bool = true
## If false, the camera node will not follow its parent.
var enable_camera_follow: bool = true
## If false, the camera will not respond to zoom input.
var enable_camera_zoom: bool = true
## If false, the camera will not tilt.
var enable_camera_tilt: bool = true
## If false, the camera will not rotate horizontally.
var enable_camera_horizontal_rotation: bool = true
## The current zoom (distance) away from the pivot.
@onready var zoom: float = distance_from_pivot

# Components

## The [Camera3D] node that this [PlayableCharacterCamera] controls.
@onready var camera: Camera3D = %WorldCamera
## The point at which the [member camera_target] will rotate around.
@onready var camera_rotation_pivot: Node3D = %RotationPivot
## The point which the [member camera_target] is offset by.
@onready var camera_offset_pivot: Node3D = %OffsetPivot
## The [SpringArm3D] that connects to the [member camera_target]. 
@onready var camera_spring_arm: SpringArm3D = %CameraSpringArm
## The position that the [member camera] moves towards.
@onready var camera_target: Node3D = %CameraTarget
## The [CameraShaker] component that handles camera shake for this [PlayableCharacterCamera].
@onready var camera_shaker: CameraShaker = %CameraShaker

func initialize(playable_character: PlayableCharacter):
	camera.top_level = true
	super(playable_character)

func _physics_process(delta):
	if not is_active:
		return
	_update_camera_properties()
	if Engine.is_editor_hint() :
		camera_target.global_position = Vector3(0., 0., 1.).rotated(
			Vector3(1., 0., 0.),
			deg_to_rad(initial_dive_angle_deg)
			).rotated(
				Vector3(0., 1., 0.),
				deg_to_rad(-camera_horizontal_rotation_deg)
			) * camera_spring_arm.spring_length + camera_spring_arm.global_position
	
	_tween_camera_to_marker()
	
	camera_offset_pivot.global_position = camera_offset_pivot.get_parent().to_global(Vector3(pivot_offset.x, pivot_offset.y, 0.0))
	camera_rotation_pivot.global_rotation_degrees.x = initial_dive_angle_deg
	camera_rotation_pivot.global_position = global_position
	
	if enable_input:
		_process_zoom_input(delta)
		_process_tilt_input()
		_process_horizontal_rotation_input()
	
	_update_zoom()
	_update_camera_tilt()
	_update_camera_horizontal_rotation()

func _unhandled_input(event):
	if not is_active:
		return
	if not enable_input:
		return
	
	if mouse_follow and event is InputEventMouseMotion:
		camera_horizontal_rotation_deg += event.relative.x * 0.1 * mouse_x_sensitivity
		camera_tilt_deg -= event.relative.y * 0.02 * mouse_y_sensitivity
		camera_tilt_deg = clampf(camera_tilt_deg, tilt_lower_limit_deg, tilt_upper_limit_deg)
		return

## Returns the forwards direction of the camera.
func get_front_direction():
	var dir : Vector3 = camera_offset_pivot.global_position - camera.global_position
	dir.y = 0.
	dir = dir.normalized()
	return dir
## Returns the backwards direction of the camera.
func get_back_direction():
	return -get_front_direction()
## Returns the left direction of the camera.
func get_left_direction():
	return get_front_direction().rotated(Vector3.UP, PI/2)
## Returns the right direction of the camera.
func get_right_direction():
	return get_front_direction().rotated(Vector3.UP, -PI/2)

## Returns the horizontal rotation in radians of the camera. [br]
## Note: If [member enable_input] is false, this will return the rotation of the [member camera].
## Else, this will returns the rotation of the [member camera_rotation_pivot].
func get_horizontal_rotation() -> float:
	if not enable_input:
		return camera.global_rotation.y
	
	return camera_rotation_pivot.global_rotation.y

func _set_when_ready(node_path: NodePath, property_name: StringName, value: Variant) :
	if not is_node_ready():
		await ready
		get_node(node_path).set(property_name, value)
	else :
		get_node(node_path).set(property_name, value)

func _update_camera_properties():
	if not is_active:
		return
	camera.keep_aspect = keep_aspect
	camera.cull_mask = cull_mask
	camera.doppler_tracking = doppler_tracking
	camera.projection = projection
	camera.fov = fov
	camera.near = near
	camera.far = far
	if camera.environment != environment:
		camera.environment = environment
	if camera.attributes != attributes:
		camera.attributes = attributes

func _tween_camera_to_marker():
	if not is_active:
		return
	if not enable_camera_follow:
		return
	camera.global_position = lerp(camera.global_position, camera_target.global_position, camera_speed)

func _process_zoom_input(delta: float):
	if Engine.is_editor_hint():
		return
	if not is_active:
		return
	if not InputMap.has_action(zoom_in_input_action) or not InputMap.has_action(zoom_out_input_action):
		return
	if Input.is_action_just_released(zoom_in_input_action):
		zoom = lerpf(zoom, zoom - zoom_speed, delta * 40)
		zoom = clampf(zoom, max_zoom, min_zoom)
	elif Input.is_action_just_released(zoom_out_input_action):
		zoom = lerpf(zoom, zoom + zoom_speed, delta * 40)
		zoom = clampf(zoom, max_zoom, min_zoom)
func _process_tilt_input() :
	if not is_active:
		return
	if not InputMap.has_action(tilt_up_input_action) or not InputMap.has_action(tilt_down_input_action):
		return
	var tilt_variation = Input.get_action_strength(tilt_up_input_action) - Input.get_action_strength(tilt_down_input_action)
	tilt_variation = tilt_variation * get_process_delta_time() * 5 * tilt_sensitivity
	camera_tilt_deg = clamp(
		camera_tilt_deg + tilt_variation,
		tilt_lower_limit_deg - initial_dive_angle_deg,
		tilt_upper_limit_deg - initial_dive_angle_deg
	)
		
func _process_horizontal_rotation_input() :
	if not is_active:
		return
	if not InputMap.has_action(rotate_camera_right_input_action) or not InputMap.has_action(rotate_camera_left_input_action):
		return
	var camera_horizontal_rotation_variation = Input.get_action_strength(rotate_camera_right_input_action) -  Input.get_action_strength(rotate_camera_left_input_action)
	camera_horizontal_rotation_variation = camera_horizontal_rotation_variation * get_process_delta_time() * 30 * horizontal_rotation_sensitivity
	camera_horizontal_rotation_deg += camera_horizontal_rotation_variation

func _update_zoom():
	if Engine.is_editor_hint():
		return
	if not is_active:
		return
	if not enable_camera_zoom:
		return
	%CameraSpringArm.spring_length = zoom
func _update_camera_tilt():
	if Engine.is_editor_hint():
		return
	if not is_active:
		return
	if not enable_camera_tilt:
		return
	var tilt_final_val = clampf(
		initial_dive_angle_deg + camera_tilt_deg,
		tilt_lower_limit_deg,
		tilt_upper_limit_deg
	)
	var tween = create_tween()
	tween.tween_property(camera, "global_rotation_degrees:x", tilt_final_val, 0.1)
func _update_camera_horizontal_rotation() :
	if Engine.is_editor_hint():
		return
	if not is_active:
		return
	if not enable_camera_horizontal_rotation:
		return
	var tween = create_tween()
	tween.tween_property(camera_rotation_pivot, "global_rotation_degrees:y", camera_horizontal_rotation_deg * -1, 0.1).as_relative()
	camera_horizontal_rotation_deg = 0.0 # reset the value
	var vect_to_offset_pivot: Vector2 = (
		Vector2(camera_offset_pivot.global_position.x, camera_offset_pivot.global_position.z)
		-
		Vector2(camera.global_position.x, camera.global_position.z)
	).normalized()
	camera.global_rotation.y = -Vector2(0., -1.).angle_to(vect_to_offset_pivot.normalized())
