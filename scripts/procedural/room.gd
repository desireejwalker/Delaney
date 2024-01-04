class_name Room

var is_hub_room: bool
var is_sub_room: bool

var rect: Rect2

var physics_body: RigidBody2D : get = _get_physics_body
func _get_physics_body():
	return physics_body

var collision_shape:CollisionShape2D

func _init(rect: Rect2):
	self.rect = rect
	
	physics_body = RigidBody2D.new()
	physics_body.gravity_scale = 0
	physics_body.linear_damp = 999
	physics_body.mass = 999
	physics_body.lock_rotation = true
	
	physics_body.max_contacts_reported = 100
	physics_body.contact_monitor = true
	
	collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = rect.size
	collision_shape.shape = rect_shape 
	
	physics_body.add_child(collision_shape)
