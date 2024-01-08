class_name FloorGenerationVisualizer extends Node2D

var _floor_generator: FloorGenerator

var _mesh_array: Array[MeshInstance2D]

func _init(floor_generator: FloorGenerator):
	self._floor_generator = floor_generator
	_floor_generator.floor_generated.connect(_do_visualization)

func _draw():
	var floor_generation_output = _floor_generator.get_current_output()
	if not floor_generation_output:
		return
	
	for edge in floor_generation_output.get_floor_graph():
		draw_line(edge.point_a, edge.point_b, Color.BLUE)

func _do_visualization():
	var floor_generation_output = _floor_generator.get_current_output()
	
	# create a mesh for every room in the current floor generation output
	# for room in floor_generation_output.get_rooms():
	# 	var room_mesh_instance = _rect_to_quad(room.rect)
	# 	room_mesh_instance.modulate = Color.DARK_RED
	# 	_mesh_array.append(room_mesh_instance)
	for hub_room in floor_generation_output.get_hub_rooms():
		var room_mesh_instance = _rect_to_quad(hub_room.rect)
		room_mesh_instance.modulate = Color.GOLDENROD
		room_mesh_instance.z_index = -100
		_mesh_array.append(room_mesh_instance)
	# for sub_room in floor_generation_output.get_sub_rooms():
	# 	var room_mesh_instance = _rect_to_quad(sub_room.rect)
	# 	room_mesh_instance.modulate = Color.ROYAL_BLUE
	# 	_mesh_array.append(room_mesh_instance)
	
	# then create path meshes...
	for path in floor_generation_output.get_paths():
		var path_mesh_instance = _rect_to_quad(path)
		_mesh_array.append(path_mesh_instance)
	
	# add all meshes as children of this node
	for mesh in _mesh_array:
		add_child(mesh)
	
	# queue redraw for graph visualization
	queue_redraw()

func _rect_to_quad(rect: Rect2) -> MeshInstance2D:
	var mesh_instance_2d = MeshInstance2D.new()
	
	# create room mesh and set its size as the size of the room	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = rect.size
	
	# set the mesh for the mesh instance as the room mesh
	mesh_instance_2d.mesh = quad_mesh
	# set its position as well
	mesh_instance_2d.position = rect.position
	
	return mesh_instance_2d

