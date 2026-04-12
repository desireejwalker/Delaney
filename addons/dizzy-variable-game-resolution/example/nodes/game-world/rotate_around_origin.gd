extends CSGBox3D

var direction_to_node: Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction_to_node = Vector3.ZERO.direction_to(self.global_position)
	var distance = Vector3.ZERO.distance_to(self.global_position)
	var rotated = direction_to_node.rotated(Vector3.UP, PI * delta * 0.1)
	global_position = rotated * distance
