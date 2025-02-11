class_name Monster extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@onready var player_range_area_2d: Area2D = $PlayerRangeArea2D
@onready var wander_range_area_2d: Area2D = $WanderRangeArea2D
@onready var wander_range_collision_shape_2d: CollisionShape2D = $WanderRangeArea2D/CollisionShape2D
@onready var line_of_sight_ray_cast_2d: RayCast2D = $LineOfSightRayCast2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var health: int = 100

var is_spawned: bool = false
var is_dead: bool = false

var player: Delaney

@export var movement_speed: float

# Called when the node enters the scene tree for the first time.
func _ready():
	wander_range_area_2d.top_level = true
	wander_range_area_2d.global_position = global_position
	
	navigation_agent_2d.velocity_computed.connect(_on_velocity_computed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_to(target: Vector2) -> void:
	if target == navigation_agent_2d.target_position:
		return
	
	navigation_agent_2d.target_position = target

func _physics_process(_delta):
	if player:
		line_of_sight_ray_cast_2d.target_position = player.position - position
	else:
		line_of_sight_ray_cast_2d.target_position = Vector2.ZERO
	#if line_of_sight_ray_cast_2d.get_collider():
		#print(line_of_sight_ray_cast_2d.get_collider())
	
	var next_position = navigation_agent_2d.get_next_path_position()
	var new_velocity: Vector2 = (next_position - position).normalized() * movement_speed
	navigation_agent_2d.set_velocity(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _on_player_range_area_2d_body_entered(body):
	if body is Delaney:
		player = body

func _on_player_range_area_2d_body_exited(body):
	if body is Delaney:
		player = null
