class_name BowyerWatson

const INT64_MAX = 9223372036854775807
const INT64_MIN = -9223372036854775808

static func calc_super_triangle(points: Array) -> Triangle:
	var min_x = INT64_MAX
	var max_x = INT64_MIN
	var min_y = INT64_MAX
	var max_y = INT64_MIN
	
	# find the bounds of the provided points
	for point in points:
		if (point.x < min_x):
			min_x = point.x
		if (point.x > max_x):
			max_x = point.x
		if (point.y < min_y):
			min_y = point.y
		if (point.y > min_y):
			min_y = point.y
	
	# get the difference from max_x and min_x
	var delta_x = (max_x - min_x + 1)
	
	# create a "super triangle" containing all point.
	var point_a = Vector2(min_x - delta_x - 1, min_y - 1)
	var point_b = Vector2(min_x + delta_x, max_y + (max_y - min_y) + 1)
	var point_c = Vector2(max_x + delta_x + 1, min_y - 1)
	
	return Triangle.new(point_a, point_b, point_c)

static func do_triangulation(points: Array) -> Array:
	var super_triangle := calc_super_triangle(points)
	var triangulation := [ super_triangle ]
	
	for point in points:
		# for every triangle in the current triangulation iteration,
		# if the current point is within the triangle's circumcenter,
		# add it to the bad triangles list, as this triangle needs to
		# be re-triangulated
		var bad_triangles: Array[Triangle] = []
		for triangle in triangulation:
			if triangle.circumcircle_contains(point):
				bad_triangles.append(triangle)
		
		# Find the polygon formed by the edges of the invalid triangles
		var polygon: Array[Edge] = []
		
		# find edges of bad triangles that outline the current triangulation iteration.
		for triangle in bad_triangles:
			for edge in triangle.edges:
				var is_shared := false
				for other_triangle in bad_triangles:
					if triangle == other_triangle:
						continue
					if other_triangle.has_edge(edge):
						is_shared = true
				
				if not is_shared:
					polygon.append(edge);
		
		# remove all bad triangles from the current triangulation iteration
		for triangle in bad_triangles:
			triangulation.erase(triangle)
		
		# create a new triangule for every edge in the polygon with the current point
		for edge in polygon:
			triangulation.append(Triangle.new(point, edge.point_a, edge.point_b))
	
	# remove all triangles that share a vertex with the initial super triangle.
	triangulation = triangulation.filter(func(triangle): return not triangle.has_vertex_from(super_triangle))
	
	return triangulation
