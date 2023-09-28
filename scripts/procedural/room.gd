class_name Room

var is_hub_room
var is_sub_room

var position: Vector2
var size: Vector2
var center: Vector2

var physics_body:RigidBody2D : get = _get_physics_body
func _get_physics_body():
	return physics_body
	
var collision_shape:CollisionShape2D

func _init(position:Vector2i, size:Vector2i):
	self.position = position
	self.size = size
	self.center = position + (size / 2)
	
	physics_body = RigidBody2D.new()
	physics_body.gravity_scale = 0
	physics_body.linear_damp = 999
	physics_body.mass = 999
	physics_body.lock_rotation = true
	
	physics_body.max_contacts_reported = 100
	physics_body.contact_monitor = true
	
	collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	collision_shape.shape = rect 
	
	physics_body.add_child(collision_shape)
