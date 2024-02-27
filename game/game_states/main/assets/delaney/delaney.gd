class_name Delaney extends RigidBody2D

const DEFAULT_SPEED = 600
const DEFAULT_DAMPING = 3
const DEFAULT_HEAVY_ATTACK_SPEED = 600

@onready var sprites := $Sprites
@onready var animation_player := $Sprites/AnimationPlayer
@onready var _finite_state_machine := $FiniteStateMachine

# debug
@onready var debug_content_label := $Debug/ContentLabel

# movement
signal on_footstep(terrain_type: int)

const LIGHT_FOOTSTEP_SCENE := preload("res://scenes/burst/light_footstep.tscn")
const FOOTSTEP_SOUNDS := [
	[
		preload("res://audio/boot_step/boot_step_1.ogg"),
		preload("res://audio/boot_step/boot_step_2.ogg"),
		preload("res://audio/boot_step/boot_step_3.ogg"),
	],
	# originates from 073303_footsteps-on-stone-39947.mp3 from pixabay.com
	[
		preload("res://audio/boot_step/boot_step_stony_1.ogg"),
		preload("res://audio/boot_step/boot_step_stony_2.ogg"),
		preload("res://audio/boot_step/boot_step_stony_3.ogg")
	],
	# originates from running-in-grass-6237.mp3 from pixabay.com
	[
		preload("res://audio/boot_step/boot_step_grassy_1.ogg"),
		preload("res://audio/boot_step/boot_step_grassy_2.ogg"),
		preload("res://audio/boot_step/boot_step_grassy_3.ogg")
	]
]

@onready var footstep_audio_stream_player_2d = $FootstepAudioStreamPlayer2D

var movement_direction := Vector2.ZERO
var mouse_direction := Vector2.ZERO
var tile_position: Vector2i

# facing direction and angle
var angle_radians := 0.0
func set_angle_radians(radians: float):
	angle_radians = radians
	angle_degrees = rad_to_deg(angle_radians)
	handle_player_rotation()
var angle_degrees := 0.0
func set_angle_degrees(degrees: float):
	angle_degrees = degrees
	
	if angle_degrees > 180:
		angle_degrees -= 360
	
	angle_radians = deg_to_rad(angle_degrees)
	handle_player_rotation()

enum Direction {
	SOUTH,
	SOUTH_EAST,
	EAST,
	NORTH_EAST,
	NORTH,
	NORTH_WEST,
	WEST,
	SOUTH_WEST,
}
var last_facing_direction := Direction.SOUTH
var facing_direction := Direction.SOUTH
var facing_vector := Vector2.DOWN.normalized()
var did_facing_change := false
var last_facing_animation_position := 0.0

# attack
const LIGHT_ATTACK_SOUNDS := [
	# originates from short-whoosh-13x-14526.mp3 from pixabay.com
	preload("res://audio/attack/light_attack_1.ogg"),
	preload("res://audio/attack/light_attack_2.ogg"),
	preload("res://audio/attack/light_attack_3.ogg"),
	preload("res://audio/attack/light_attack_4.ogg"),
	preload("res://audio/attack/light_attack_5.ogg"),
	preload("res://audio/attack/light_attack_6.ogg"),
	preload("res://audio/attack/light_attack_7.ogg"),
	preload("res://audio/attack/light_attack_8.ogg"),
	preload("res://audio/attack/light_attack_10.ogg"),
	preload("res://audio/attack/light_attack_11.ogg"),
	preload("res://audio/attack/light_attack_12.ogg"),
	preload("res://audio/attack/light_attack_13.ogg")
]

@onready var light_dust := $Particles/LightDust

var heavy_attack_speed = DEFAULT_HEAVY_ATTACK_SPEED
var auto_target_light_attack = true

# launch
const LAUNCH_LEVEL_PARTICLE_SCENES := [
	preload("res://scenes/burst/heavy_attack_level_1.tscn"),
	preload("res://scenes/burst/heavy_attack_level_2.tscn"),
	preload("res://scenes/burst/heavy_attack_level_3.tscn")
]

@onready var launch_level_1_trail := $Particles/LaunchLevel1Trail
@onready var launch_level_2_trail := $Particles/LaunchLevel2Trail
@onready var launch_level_3_trail := $Particles/LaunchLevel3Trail

func _ready():
	_finite_state_machine.start()

func _physics_process(delta):
	movement_direction = get_normalized_input_direction()
	mouse_direction = get_normalized_mouse_direction()
	tile_position = get_tile_position()

func _process(delta):
	handle_player_rotation()
	handle_player_animation()
	
	debug_content_label.text = get_debug_info()

func _on_player_footstep():
	on_footstep.emit(_get_terrain_type_underfoot())

func get_normalized_input_direction():
	var direction = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return direction.normalized()

func get_normalized_mouse_direction():
	var direction = Vector2.ZERO
	direction = get_global_mouse_position() - get_transform().get_origin()
	return direction.normalized()
	
func handle_player_rotation():
	last_facing_direction = facing_direction
	
	if (angle_degrees >= -22.5 and angle_degrees < 22.5):
		facing_direction = Direction.EAST
		facing_vector = Vector2.RIGHT.normalized()
	elif (angle_degrees >= 22.5 and angle_degrees < 67.5): 
		facing_direction = Direction.SOUTH_EAST
		facing_vector = Vector2.ONE.normalized()
	elif (angle_degrees >= 67.5 and angle_degrees < 112.5): 
		facing_direction = Direction.SOUTH
		facing_vector = Vector2.DOWN.normalized()
	elif (angle_degrees >= 112.5 and angle_degrees < 157.5): 
		facing_direction = Direction.SOUTH_WEST
		facing_vector = Vector2(-1, 1).normalized()
	elif (angle_degrees >= 157.5 and angle_degrees <= 180) or (angle_degrees >= -180 and angle_degrees < -157.5): 
		facing_direction = Direction.WEST
		facing_vector = Vector2(-1, 0).normalized()
	elif (angle_degrees >= -157.5 and angle_degrees < -112.5): 
		facing_direction = Direction.NORTH_WEST
		facing_vector = Vector2(-1, -1).normalized()
	elif (angle_degrees >= -112.5 and angle_degrees < -67.5): 
		facing_direction = Direction.NORTH
		facing_vector = Vector2(0, -1).normalized()
	elif (angle_degrees >= -67.5 and angle_degrees < -22.5): 
		facing_direction = Direction.NORTH_EAST
		facing_vector = Vector2(1, -1).normalized()
	else: 
		facing_direction = Direction.SOUTH
		facing_vector = Vector2.DOWN.normalized()
		
	if facing_direction != last_facing_direction:
		did_facing_change = true
	else:
		did_facing_change = false

func handle_player_animation():	
	if did_facing_change:
		last_facing_animation_position = animation_player.current_animation_position

# HELPER FUNCTIONS
func get_tile_position() -> Vector2i:
	var game_tilemap: TileMap = GameManager.get_instance().get_node("FloorManager/Floor/TileMap")
	if not game_tilemap:
		return Vector2i.ZERO
	if not game_tilemap.tile_set:
		return Vector2i.ZERO
	return game_tilemap.local_to_map(game_tilemap.to_local(global_position))

func get_debug_info() -> String:
	var debug_info_dictionary := {
		"current_state": _finite_state_machine.active_state.name.to_pascal_case(),
		"facing_angle_degrees": str(floor(angle_degrees)),
		"linear_velocity": str(linear_velocity.floor()),
		"speed": str(floor(linear_velocity.length()))
	}
	
	var debug_info := ""
	for key in debug_info_dictionary.keys():
		debug_info += key + ": " + debug_info_dictionary[key] + "\n"
	return debug_info

func _get_uppermost_tilemap_layer(coords: Vector2i) -> int:
	var game_tilemap: TileMap = GameManager.get_instance().get_node("FloorManager/Floor/TileMap")
	for i in range(game_tilemap.get_layers_count() - 1, -1, -1):

		# if there is no tile on this layer, continue
		if game_tilemap.get_cell_atlas_coords(i, coords) == -Vector2i.ONE:
			continue
		
		return i
	
	# couldn't find the highest layer in the tilemap
	return -1

func _get_terrain_type_underfoot() -> int:
	var game_tilemap: TileMap = GameManager.get_instance().get_node("FloorManager/Floor/TileMap")
	var layer = _get_uppermost_tilemap_layer(tile_position)
	var underfoot_tile_data = game_tilemap.get_cell_tile_data(layer, tile_position)

	if underfoot_tile_data == null:
		return 0 # zero is the default terrain type

	return underfoot_tile_data.get_custom_data_by_layer_id(0) as int # terrain_type layer is 0, cast to an int

