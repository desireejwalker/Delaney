class_name Delaunay extends Resource

func calculate_super_triangle(points) -> Triangle:
	var x_min = 9223372036854775807
	var x_max = -9223372036854775808
	var y_min = 9223372036854775807
	var y_max = -9223372036854775808
	
	for point in points:
		if point.x < x_min:
			x_min = point.x
		if point.x > x_max:
			x_max = point.x
		if point.y < y_min:
			y_min = point.y
		if point.y > y_max:
			y_max = point.y
	
	var dx = (x_max - x_min + 1) / 2
	
	# just select a random triangle containing all points
	var point_1 = Vector2(x_min - dx - 1, y_min - 1)
	var point_2 = Vector2(x_min + dx, y_max + (y_max - y_min) + 1)
	var point_3 = Vector2(x_max + dx + 1, y_min - 1)
	
	return Triangle.new(point_1, point_2, point_3)

func triangulate(points) -> Array:
	var super_triangle = calculate_super_triangle(points)
	var triangulation = [
		super_triangle
	]
	
	for point in points:
		var bad_triangles = []
		for triangle in triangulation:
			if triangle.circum_circle_contains(point):
				bad_triangles.append(triangle)
		
		var polygon = []
		for bad_triangle in bad_triangles:
			for edge in bad_triangle.edges:
				var is_shared_edge = false
				for other_triangle in bad_triangles:
					if bad_triangle == other_triangle:
						continue
					
					if other_triangle.has_edge(edge):
						is_shared_edge = true
				
				if !is_shared_edge:
					polygon.append(edge)
		
		# remove all bad triangles from the triangulation
		var triangle_indexes_to_remove = []
		for i in range(triangulation.size()):
			for bad_triangle in bad_triangles:
				if (bad_triangle.equals(triangulation[i])):
					triangle_indexes_to_remove.append(i)
		for i in triangle_indexes_to_remove:
			triangulation.remove_at(i)
		
		for edge in polygon:
			triangulation.append(Triangle.new(point, edge.point_a, edge.point_a))
	
	triangulation = triangulation.filter(func(triangle): return !triangle.has_vertex_from(super_triangle))
	
	return triangulation
