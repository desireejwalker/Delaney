class_name Prim extends Resource

func find_minimum_spanning_tree(points) -> AStar2D:
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object
	# source: https://kidscancode.org/blog/2018/12/godot3_procgen7/
	
	# Initialize the AStar and add the first point
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), points.pop_front())
	
	# Repeat until no more points remain
	while points:
		var min_dist = INF  # Minimum distance found so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		
		# Loop through the points in the path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			# Loop through the remaining nodes in the given array
			for p2 in points:
				# If the point is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		
		# Insert the resulting point into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the point from the array so it isn't visited again
		points.erase(min_p)
	return path
