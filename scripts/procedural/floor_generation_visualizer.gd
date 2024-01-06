class_name FloorGenerationVisualizer extends Node2D

var _floor_generator: FloorGenerator

func _init(floor_generator: FloorGenerator):
	self._floor_generator = floor_generator

func _create_room_mesh(room: Room) -> MeshInstance2D:
	var room_rect = room.rect
	var room_mesh_instance_2d = MeshInstance2D.new()
	
	# create room mesh and set its size as the size of the room	
	var room_mesh = QuadMesh.new()
	room_mesh.size = room_rect.size
	
	# set the mesh for the mesh instance as the room mesh
	room_mesh_instance_2d.mesh = room_mesh
	# set its position as well
	room_mesh_instance_2d.position = room_rect.position
	
	return room_mesh_instance_2d

