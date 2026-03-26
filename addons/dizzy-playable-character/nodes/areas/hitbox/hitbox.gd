@tool
class_name Hitbox
extends Area3D

@onready var _collision_shape_3d: CollisionShape3D = %CollisionShape3D

var _remaining_life: int = 0

@export var source: Node
## how many times this hitbox may be "consumed" by a hurtbox.
## -1 = infinity
@export var life: int = 5
@export var damage_instance: DamageInstance
@export var shape: BoxShape3D:
	set(value):
		shape = value
		%CollisionShape3D.shape = shape

func _ready() -> void:
	if source and damage_instance:
		damage_instance.source = source
	
	if not life == -1:
		_remaining_life = life
	%CollisionShape3D.shape = shape
	
	disable()

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		print(body.get_parent())

# since setting a hitbox as monitorable does not automatically
# fire the area_entered event in a hitbox thats already intersected,
# get overlapping areas on enable and call the receiving function
# manually.
func enable():
	monitorable = true
	
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if not area is Hurtbox:
			continue
		
		area._on_area_entered(self)
func disable():
	monitorable = false

func try_consume() -> bool:
	return (_remaining_life - 1 > 0) or life == -1
func consume() -> DamageInstance:
	if not life == -1:
		_remaining_life -= 1
	var new_damage_instance = damage_instance.duplicate_instance()
	return new_damage_instance
