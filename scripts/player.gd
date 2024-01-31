extends RigidBody2D

var game_manager: GameManager

var animation_player: AnimationPlayer

var launch_trail_level_1: GPUParticles2D
var launch_trail_level_2: GPUParticles2D
var launch_trail_level_3: GPUParticles2D

var dust_light: GPUParticles2D

const DEFAULT_SPEED = 600
const DEFAULT_DAMPING = 3
const DEFAULT_HEAVY_ATTACK_SPEED = 80

var heavy_attack_speed = DEFAULT_HEAVY_ATTACK_SPEED

var tile_position: Vector2i

var angle_radians = 0
var angle_degrees = 0

var last_facing = "none"
var facing = "south"
var facing_vector = Vector2.DOWN.normalized()
var did_facing_change = false
var last_facing_animation_position = 0.0

var movement = "idle"

var attack = "none"
var is_light_attack_animation_completed = false
var auto_target_light_attack = true

var recovery = "none"

var launch_level = -1

@onready var footstep_audio_stream_player_2d = $FootstepAudioStreamPlayer2D
var footstep_sounds := [
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

func _ready():
	animation_player = $sprites/AnimationPlayer
	
	launch_trail_level_1 = load("res://scenes/trails/launch_trail_level_1.tscn").instantiate().get_node("GPUParticles2D")
	add_child(launch_trail_level_1.get_parent())
	launch_trail_level_2 = load("res://scenes/trails/launch_trail_level_2.tscn").instantiate().get_node("GPUParticles2D")
	add_child(launch_trail_level_2.get_parent())
	launch_trail_level_3 = load("res://scenes/trails/launch_trail_level_3.tscn").instantiate().get_node("GPUParticles2D")
	add_child(launch_trail_level_3.get_parent())
	
	dust_light = load("res://scenes/trails/dust_light.tscn").instantiate().get_node("GPUParticles2D")
	add_child(dust_light.get_parent())
	dust_light.translate(Vector2(0, 20))

	game_manager = GameManager.get_instance()
	

func _physics_process(delta):
	if (attack == "none" and launch_level != -1):
		pass
	elif (attack == "heavy" and launch_level != -1):
		handle_player_movement(delta, get_normalized_mouse_direction(), DEFAULT_SPEED * 0.2, DEFAULT_DAMPING, false, false)
	elif (attack == "none" and recovery == "none"):
		handle_player_movement(delta, get_normalized_input_direction(), DEFAULT_SPEED, DEFAULT_DAMPING, true, true)
	elif (attack == "light" and recovery == "light"):
		handle_player_movement(delta, get_normalized_input_direction(), DEFAULT_SPEED * 1.6, DEFAULT_DAMPING, true, true)
		
	handle_player_light_recovery()
	handle_player_heavy_recovery()
	
	handle_player_rotation()

	tile_position = get_tile_position()
	print(_get_terrain_type_underfoot())


func _process(delta):
	handle_player_attack(delta)
	handle_player_animation()
	
func _on_animation_player_animation_finished(_anim_name):
	if attack == "light":
		is_light_attack_animation_completed = true

func _on_player_footstep():
	# play random footstep sound according to the terrain type underfoot
	var terrain_type = _get_terrain_type_underfoot()
	footstep_audio_stream_player_2d.stream = footstep_sounds[terrain_type][randi_range(0, 2)]
	footstep_audio_stream_player_2d.play()
	
	# create particle effects
	var footstep_light:Node2D = load("res://scenes/burst/footstep_light.tscn").instantiate()
	get_tree().root.add_child(footstep_light)
	footstep_light.translate(position + Vector2(0, 20))

func get_normalized_input_direction():
	var direction = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return direction.normalized()

func get_normalized_mouse_direction():
	var direction = Vector2.ZERO
	direction = get_global_mouse_position() - get_transform().get_origin()
	return direction.normalized()

func get_tile_position() -> Vector2i:
	var game_tilemap: TileMap = game_manager.get_node("FloorManager/Floor/TileMap")
	return game_tilemap.local_to_map(game_tilemap.to_local(global_position))

func handle_player_movement(_delta, normalized_direction, speed, damping, update_facing_angle: bool, update_animation_speed: bool):
	linear_damp = damping
	
	# check if the linear_velocity is small enough to just set to zero
	# NOTE: there is likely a better way to do this... search later.
	if linear_velocity.length() <= 1:
		movement = "idle"
	else:
		movement = "walk"
	
	# apply forces in movement direction
	apply_central_force(normalized_direction * speed)
	
	if update_facing_angle:
		# set facing angle based on velocity
		angle_radians = atan2(linear_velocity.y, linear_velocity.x)
		angle_degrees = rad_to_deg(angle_radians)
	
	if update_animation_speed:
		# adjust animation speed to look consistent with speed
		animation_player.set_speed_scale((linear_velocity.length() / 200) + 1)
	
func handle_player_rotation():
	last_facing = facing
	
	if (angle_degrees >= -22.5 and angle_degrees < 22.5): 
		facing = "east"
		facing_vector = Vector2.RIGHT.normalized()
	elif (angle_degrees >= 22.5 and angle_degrees < 67.5): 
		facing = "south_east"
		facing_vector = Vector2.ONE.normalized()
	elif (angle_degrees >= 67.5 and angle_degrees < 112.5): 
		facing = "south"
		facing_vector = Vector2.DOWN.normalized()
	elif (angle_degrees >= 112.5 and angle_degrees < 157.5): 
		facing = "south_west"
		facing_vector = Vector2(-1, 1).normalized()
	elif (angle_degrees >= 157.5 and angle_degrees <= 180) or (angle_degrees >= -180 and angle_degrees < -157.5): 
		facing = "west"
		facing_vector = Vector2(-1, 0).normalized()
	elif (angle_degrees >= -157.5 and angle_degrees < -112.5): 
		facing = "north_west"
		facing_vector = Vector2(-1, -1).normalized()
	elif (angle_degrees >= -112.5 and angle_degrees < -67.5): 
		facing = "north"
		facing_vector = Vector2(0, -1).normalized()
	elif (angle_degrees >= -67.5 and angle_degrees < -22.5): 
		facing = "north_east"
		facing_vector = Vector2(1, -1).normalized()
	else: 
		facing = "south"
		facing_vector = Vector2.DOWN.normalized()
		
	if facing != last_facing:
		did_facing_change = true
	else:
		did_facing_change = false

func handle_player_animation():	
	if did_facing_change:
		last_facing_animation_position = animation_player.current_animation_position
	
	if facing == "south":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_south")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_south")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_south")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_south")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "south_east":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_southeast")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_southeast")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_southeast")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_southeast")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "east":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_east")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_east")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_east")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_east")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "north_east":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_northeast")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_northeast")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_northeast")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_northeast")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "north":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_north")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_north")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_north")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_north")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "north_west":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_northwest")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_northwest")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_northwest")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_northwest")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "west":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_west")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_west")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_west")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_west")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
	elif facing == "south_west":
		if (attack == "heavy" and recovery != "heavy"):
			animation_player.play("player_heavy_attack_southwest")
		elif (attack == "light" and recovery != "light"):
			animation_player.play("player_light_attack_southwest")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "idle":
			animation_player.play("player_idle_southwest")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)
		elif movement == "walk":
			animation_player.play("player_walk_southwest")
			if did_facing_change:
				animation_player.seek(last_facing_animation_position)


func handle_player_attack(delta):
	if recovery != "none":
		return
	
	# while the player is performing the heavy attack, once the player
	# lets go of the attack key, end the heavy attack.
	if attack == "heavy":
		if not Input.is_action_pressed("attack"):
			handle_player_heavy_attack_end()
		else:
			handle_player_heavy_attack(delta)
	elif attack == "light":
		if is_light_attack_animation_completed:
			handle_player_light_attack_end()
		else:
			handle_player_light_attack(delta)
	else:
		if Input.is_action_pressed("attack"):
			handle_player_light_attack_start()

func handle_player_light_attack_start():
	# if the weapon equipped allows for auto-targeting
	# face player in the direction of the mouse
	var dir = facing_vector
	if auto_target_light_attack:
		dir = get_normalized_mouse_direction()
		angle_radians = atan2(dir.y, dir.x)
		angle_degrees = rad_to_deg(angle_radians)
	
	# give em a little push
	apply_central_impulse(dir * 40)
	
	attack = "light"
	is_light_attack_animation_completed = false

func handle_player_light_attack(_delta):
	if (Input.is_action_pressed("recovery") and recovery == "none"):
		handle_player_light_recovery_start()	

func handle_player_light_attack_end():
	# check if player is still holding the attack button to start
	# the heavy attack and its corresponding animation.
	if Input.is_action_pressed("attack"):
		handle_player_heavy_attack_start()
	else:
		attack = "none"

func handle_player_light_recovery_start():
	recovery = "light"
	apply_central_impulse(get_normalized_input_direction() * 200)
	await get_tree().create_timer(1.0).timeout
	recovery = "none"
	if attack == "light": attack = "none"

func handle_player_light_recovery():
	if recovery != "light":
		return


func handle_player_heavy_attack_start():
	attack = "heavy"
	launch_level = 0
	
	heavy_attack_speed = DEFAULT_HEAVY_ATTACK_SPEED
	
	dust_light.emitting = true
	
	# wait 1.5s to move to launch level 1
	await get_tree().create_timer(1.5).timeout
	if attack != "heavy":
		launch_level = -1
		return
	launch_level = 1
	
	add_child(load("res://scenes/burst/heavy_attack_level_1.tscn").instantiate())
	
	heavy_attack_speed = DEFAULT_HEAVY_ATTACK_SPEED * 3
	
	# wait another 1.5s to move to launch level 2
	await get_tree().create_timer(1.5).timeout
	if attack != "heavy":
		launch_level = -1
		return
	launch_level = 2
	
	add_child(load("res://scenes/burst/heavy_attack_level_2.tscn").instantiate())
		
	heavy_attack_speed = DEFAULT_HEAVY_ATTACK_SPEED * 6
	
	# wait 2.0s to move to launch level 3
	await get_tree().create_timer(2.0).timeout
	if attack != "heavy":
		launch_level = -1
		return
	launch_level = 3
	
	add_child(load("res://scenes/burst/heavy_attack_level_3.tscn").instantiate())
	
	heavy_attack_speed = DEFAULT_HEAVY_ATTACK_SPEED * 10	

func handle_player_heavy_attack(delta):
	if attack != "heavy":
		return
	
	angle_degrees += heavy_attack_speed * delta
	if angle_degrees > 180:
		angle_degrees -= 360
	angle_radians = deg_to_rad(angle_degrees)

func handle_player_heavy_attack_end():
	attack = "none"
	dust_light.emitting = false
	
	if launch_level == 0:
		launch_level = -1
		return
	
	handle_player_launch_start(launch_level, get_normalized_mouse_direction())

func handle_player_heavy_recovery():
	if recovery != "heavy":
		return


func handle_player_launch_start(level, direction):
	linear_damp = 0
	apply_central_impulse(direction * 300 * level)
	
	# hide sprite and make the player bounce off of walls
	$sprites.visible = false
	physics_material_override.bounce = 1
	
	if level == 3:
		launch_trail_level_3.emitting = true
		await get_tree().create_timer(3.0).timeout
		launch_trail_level_3.emitting = false
	elif level == 2:
		launch_trail_level_2.emitting = true
		await get_tree().create_timer(3.0).timeout
		launch_trail_level_2.emitting = false
	else:
		launch_trail_level_1.emitting = true
		await get_tree().create_timer(3.0).timeout
		launch_trail_level_1.emitting = false
		
	$sprites.visible = true
	physics_material_override.bounce = 0
	
	launch_level = -1

# HELPER FUNCTIONS

func _get_uppermost_tilemap_layer(coords: Vector2i) -> int:
	var game_tilemap: TileMap = game_manager.get_node("FloorManager/Floor/TileMap")
	for i in range(game_tilemap.get_layers_count() - 1, -1, -1):

		# if there is no tile on this layer, continue
		if game_tilemap.get_cell_atlas_coords(i, coords) == -Vector2i.ONE:
			continue
		
		return i
	
	# couldn't find the highest layer in the tilemap
	return -1

func _get_terrain_type_underfoot() -> int:
	var game_tilemap: TileMap = game_manager.get_node("FloorManager/Floor/TileMap")
	var layer = _get_uppermost_tilemap_layer(tile_position)
	var underfoot_tile_data = game_tilemap.get_cell_tile_data(layer, tile_position)

	if underfoot_tile_data == null:
		return 0 # zero is the default terrain type

	return underfoot_tile_data.get_custom_data_by_layer_id(0) as int # terrain_type layer is 0, cast to an int
