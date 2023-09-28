class_name FloorGenerator extends Node

signal all_room_physics_bodies_sleeping
var check_all_room_physics_bodies = false

var random

var room_array:Array[Room]
var hub_room_array:Array[Room]
var average_room_size

func _init():
	random = RandomNumberGenerator.new()

func run(room_count):
	var room_size_sum = 0
	
	for i in range(room_count):
		var room:Room = Room.new(get_random_position_in_ellipsoid(100, 100), Vector2i(random.randi_range(100, 300), random.randi_range(100, 300)))
		room_size_sum += room.size.length()
		
		add_child(room.physics_body)
		
		room_array.append(room)
	
	average_room_size = room_size_sum / room_count
	
	check_all_room_physics_bodies = true
	print("waiting for physics bodies to sleep...")
	await all_room_physics_bodies_sleeping
	print("done.")
	
	print("running initial room checks...")
	for room in room_array:
		snap_room_position_to_int(room)
		
		var contacts = room.physics_body.get_contact_count()
		print("room {roomid} has {contact_count} contacts.".format({"roomid":room.to_string(), "contact_count":contacts}))
		
		mark_room_as_hub_room(room)
	print("done.")
	
	# run Delaunay triangulation and get minimum spanning tree of the output
	print("creating final floor graph...")
	var hub_room_points = []
	var point_to_room_dict = {}
	
	# find minimum point
	var delaunay = Delaunay.new()
	var kruskal = Kruskal.new()
	
	for hub_room in hub_room_array:
		var hub_room_center = Vector2i(hub_room.position + hub_room.size / 2)
		point_to_room_dict[hub_room_center] = hub_room
		hub_room_points.append(hub_room_center)
	
	var triangulation = delaunay.triangulate(hub_room_points)
	var minimum_spanning_tree = kruskal.find_minimum_spanning_tree(triangulation)
	
	# merge these graphs together and remove duplicates
	var final_graph = minimum_spanning_tree
	for edge in minimum_spanning_tree:
		if final_graph.has(edge):
			continue
		final_graph.append(edge)
	print("done.")
	
	# find paths
	print("creating paths...")
	var paths = []
	
	for point in hub_room_points:
		var hub_room_a = point_to_room_dict[point]
		var connected_edges = final_graph.filter(func(edge): return edge.point_a == Vector2(point))
		
		for edge in connected_edges:
			var hub_room_b = point_to_room_dict[edge.point_b]
			
			var midpoint = edge.center()
			var midpoint_x = int(midpoint.x)
			var midpoint_y = int(midpoint.y)
			
			# if midpoint x position is within the dimension
			# of hub_room_a, create a vertical path connecting
			# the two points
			if (midpoint_x >= hub_room_a.position.x and midpoint_x < hub_room_a.position.x + hub_room_a.size.x):
				var path = Rect2i(
						midpoint_x,
						int((hub_room_a.position.y + hub_room_a.size.y) / 2),
						5, # path thickness
						int((hub_room_b.position.y + hub_room_b.size.y) / 2) - int((hub_room_a.position.y + hub_room_a.size.y) / 2))
				
				paths.append(path)
				continue
				
			# if midpoint y position is within the dimension
			# of hub_room_a, create a horizontal path connecting
			# the two points
			if (midpoint_y >= hub_room_a.position.y and midpoint_y < hub_room_a.position.y + hub_room_a.size.y):
				var path = Rect2i(
						int((hub_room_a.position.x + hub_room_a.size.x) / 2),
						midpoint_y,
						int((hub_room_b.position.x + hub_room_b.size.x) / 2) - int((hub_room_a.position.x + hub_room_a.size.x) / 2),
						5) # path thickness
				
				paths.append(path)
				continue
				
			# else... create an L-shaped path connecting the two points
			# vertical half
			var l_half_a = Rect2i(
					int((hub_room_a.position.x + hub_room_a.size.x) / 2),
					int((hub_room_a.position.y + hub_room_a.size.y) / 2),
					5, # path thickness
					int((hub_room_b.position.y + hub_room_b.size.y) / 2) - int((hub_room_a.position.y + hub_room_a.size.y) / 2))
			# horizontal half
			var l_half_b = Rect2i(
				int((hub_room_a.position.x + hub_room_a.size.x) / 2),
				int((hub_room_a.position.y + hub_room_a.size.y) / 2),
				int((hub_room_b.position.y + hub_room_b.size.y) / 2) - int((hub_room_a.position.y + hub_room_a.size.y) / 2),
				5) # path thickness
			
			paths.append(l_half_a)
			paths.append(l_half_b)
	print("done.")
	
	# find rooms that are connected to paths
	# and mark them as sub rooms
	print("running sub room checks...")
	for room in room_array:
		if room.is_hub_room:
			continue
		
		var room_rect = Rect2i(room.position, room.size)
		for path in paths:
			if room_rect.intersects(room_rect):
				room.is_sub_room = true
	print("done.")
	
	print("ready.")

func snap_room_position_to_int(room):
	var snapped_position = Vector2(int(room.physics_body.global_position.x), int(room.physics_body.global_position.y))
	room.physics_body.global_position = snapped_position
	room.position = snapped_position
	room.physics_body.freeze = true
	
func mark_room_as_hub_room(room):
	if room.size.length() > average_room_size:
		room.is_hub_room = true
		hub_room_array.append(room)
		print("...and is a hub room. (size: {room_size})".format({"room_size":room.size.length()}))

func _physics_process(delta):
	if !check_all_room_physics_bodies:
		return
	
	if room_array.all(func(room): return room.physics_body.is_sleeping()):
		all_room_physics_bodies_sleeping.emit()
		check_all_room_physics_bodies = false

func get_random_position_in_ellipsoid(width, height):
	var t = 2 * PI * random.randf()
	var u = random.randf() + random.randf()
	var r = 0
	
	if u > 1:
		r = 2 - u
	else:
		r = u
	
	return Vector2i(int(width * r * cos(t) / 2), int(height * r * sin(t) / 2))
