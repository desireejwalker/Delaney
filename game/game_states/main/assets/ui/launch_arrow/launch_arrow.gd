class_name LaunchArrow extends Node2D

@onready var animation_player = $AnimationPlayer

var launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if launched:
		return
	
	var direction = get_global_mouse_position() - get_parent().get_transform().get_origin()
	rotation = lerp_angle(rotation, atan2(direction.y, direction.x), delta * 100)

func launch():
	launched = true
	
	var saved_global_position = global_position
	var saved_global_rotation = global_rotation
	top_level = true
	global_position = saved_global_position
	global_rotation = saved_global_rotation
	
	animation_player.play("launched")
