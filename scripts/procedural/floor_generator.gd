class_name FloorGenerator extends Node

signal _all_room_physics_bodies_sleeping
var _check_all_room_physics_bodies = false

var _average_room_size: float
var _room_array: Array[Room]
var _hub_room_array: Array[Room]
var _sub_room_array: Array[Room]

var _final_graph: Array[Edge]
var _paths: Array[Rect2i]

func run(room_count):
	_generate_initial_rooms(room_count)
	await _await_rooms_physics_bodies()
	# pick rooms that are above the average room size and mark them as "hub rooms"
	_hub_room_array = _room_array.filter(func(room): return room.rect.size.length() > _average_room_size)
	_final_graph = _create_final_graph()
	_paths = _create_paths(_final_graph)
	# pick rooms that arent hub rooms and intersect with a path rect from the path array
	_sub_room_array = _room_array.filter(func(room): return not room.is_hub_room and _room_intersects_paths(room))
	print("ready.")

func _generate_initial_rooms(count):
	var room_size_sum = 0
	
	for i in range(count):
		var room: Room = Room.new(Rect2(
				get_random_position_in_ellipsoid(100, 100), 
				Vector2i(randi_range(100, 300), randi_range(100, 300))))
		room_size_sum += room.rect.size.length()
		
		add_child(room.physics_body)
		
		_room_array.append(room)
	
	_average_room_size = room_size_sum / count

func _await_rooms_physics_bodies():
	_check_all_room_physics_bodies = true
	print("waiting for physics bodies to sleep...")
	await _all_room_physics_bodies_sleeping
	print("done.")

func snap_room_position_to_int(room):
	var snapped_position = Vector2(int(room.physics_body.global_position.x), int(room.physics_body.global_position.y))
	room.physics_body.global_position = snapped_position
	room.position = snapped_position
	room.physics_body.freeze = true

func _create_final_graph() -> Array[Edge]:
	# run Delaunay triangulation and get minimum spanning tree of the output
	print("creating final floor graph...")
	
	var delaunay: Delaunay = Delaunay.new()
	var kruskal: Kruskal = Kruskal.new()
	
	# map hub room array to center points for delaunay triangulation
	var triangulation = delaunay.triangulate(_hub_room_array.map(func(hub_room: Room): return hub_room.rect.get_center()))
	var minimum_spanning_tree = kruskal.find_minimum_spanning_tree(triangulation)
	
	# merge these graphs together and remove duplicates
	#var final_graph = minimum_spanning_tree
	#for edge in minimum_spanning_tree:
	#	if final_graph.has(edge):
	#		continue
	#	final_graph.append(edge)
	print("done.")
	return minimum_spanning_tree

func _create_paths(final_graph) -> Array[Rect2i]:
	# find paths
	print("creating paths...")
	var paths: Array[Rect2i] = []
	
	for hub_room in _hub_room_array:
		var hub_room_a = hub_room
		var connected_edges = final_graph.filter(func(edge): return edge.point_a == Vector2(hub_room.rect.get_center()))
		
		for edge in connected_edges:
			# get the hub room on the opposie edge of this room.
			var hub_room_b = _hub_room_array.filter(func(room): return room.rect.get_center() == edge.point_b)[0]
			
			var midpoint = edge.center()
			var midpoint_x = int(midpoint.x)
			var midpoint_y = int(midpoint.y)
			
			# if midpoint x position is within the dimension
			# of hub_room_a, create a vertical path connecting
			# the two points
			if (midpoint_x >= hub_room_a.rect.position.x and midpoint_x < hub_room_a.rect.position.x + hub_room_a.rect.size.x):
				var path = Rect2i(
						midpoint_x,
						int((hub_room_a.rect.position.y + hub_room_a.rect.size.y) / 2),
						5, # path thickness
						int((hub_room_b.rect.position.y + hub_room_b.rect.size.y) / 2) - int((hub_room_a.rect.position.y + hub_room_a.rect.size.y) / 2))
				
				paths.append(path)
				continue
				
			# if midpoint y position is within the dimension
			# of hub_room_a, create a horizontal path connecting
			# the two points
			if (midpoint_y >= hub_room_a.rect.position.y and midpoint_y < hub_room_a.rect.position.y + hub_room_a.rect.size.y):
				var path = Rect2i(
						int((hub_room_a.rect.position.x + hub_room_a.size.x) / 2),
						midpoint_y,
						int((hub_room_b.rect.position.x + hub_room_b.size.x) / 2) - int((hub_room_a.rect.position.x + hub_room_a.rect.size.x) / 2),
						5) # path thickness
				
				paths.append(path)
				continue
				
			# else... create an L-shaped path connecting the two points
			# vertical half
			var l_half_a = Rect2i(
					int((hub_room_a.rect.position.x + hub_room_a.rect.size.x) / 2),
					int((hub_room_a.rect.position.y + hub_room_a.rect.size.y) / 2),
					5, # path thickness
					int((hub_room_b.rect.position.y + hub_room_b.rect.size.y) / 2) - int((hub_room_a.rect.position.y + hub_room_a.rect.size.y) / 2))
			# horizontal half
			var l_half_b = Rect2i(
				int((hub_room_a.rect.position.x + hub_room_a.rect.size.x) / 2),
				int((hub_room_a.rect.position.y + hub_room_a.rect.size.y) / 2),
				int((hub_room_b.rect.position.y + hub_room_b.rect.size.y) / 2) - int((hub_room_a.rect.position.y + hub_room_a.rect.size.y) / 2),
				5) # path thickness
			
			paths.append(l_half_a)
			paths.append(l_half_b)
	print("done.")
	return paths

func _room_intersects_paths(room: Room):
	for path in _paths:
		if room.rect.intersects(path):
			return true
	return false

func _physics_process(delta):
	if not _check_all_room_physics_bodies:
		return
	
	if not _room_array.all(func(room): return room.physics_body.is_sleeping()):
		return
	
	_all_room_physics_bodies_sleeping.emit()
	_check_all_room_physics_bodies = false

func get_random_position_in_ellipsoid(width, height):
	var t = 2 * PI * randf()
	var u = randf() + randf()
	var r = 0
	
	if u > 1:
		r = 2 - u
	else:
		r = u
	
	return Vector2i(int(width * r * cos(t) / 2), int(height * r * sin(t) / 2))
