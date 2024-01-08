class_name Delaunay

# ==========
# DEPRECATED
# ==========

# func calculate_super_triangle(points) -> Triangle:
# 	var x_min = 9223372036854775807
# 	var x_max = -9223372036854775808
# 	var y_min = 9223372036854775807
# 	var y_max = -9223372036854775808
	
# 	for point in points:
# 		if point.x < x_min:
# 			x_min = point.x
# 		if point.x > x_max:
# 			x_max = point.x
# 		if point.y < y_min:
# 			y_min = point.y
# 		if point.y > y_max:
# 			y_max = point.y
	
# 	var dx = (x_max - x_min + 1) / 2
	
# 	# just select a random triangle containing all points
# 	var point_1 = Vector2(x_min - dx - 1, y_min - 1)
# 	var point_2 = Vector2(x_min + dx, y_max + (y_max - y_min) + 1)
# 	var point_3 = Vector2(x_max + dx + 1, y_min - 1)
	
# 	return Triangle.new(point_1, point_2, point_3)

# func triangulate(points) -> Array:
# 	var super_triangle: Triangle = calculate_super_triangle(points)
# 	var triangulation = [
# 		super_triangle
# 	]
	
# 	for point in points:
# 		var bad_triangles: Array[Triangle] = []
# 		for triangle in triangulation:
# 			if triangle.circum_circle_contains(point):
# 				if !bad_triangles.has(triangle):
# 					bad_triangles.append(triangle)
		
# 		var polygon: Array[Edge] = []
# 		for bad_triangle in bad_triangles:
# 			for edge in bad_triangle.edges:
# 				var is_shared_edge = false
# 				for other_triangle in bad_triangles:
# 					if bad_triangle == other_triangle:
# 						continue
# 					if other_triangle.has_edge(edge):
# 						is_shared_edge = true
# 				if !is_shared_edge:
# 					if !polygon.has(edge):
# 						polygon.append(edge)
		
# 		# remove all bad triangles from the triangulation
# 		var no_bad_triangles = triangulation.filter(func(triangle): return !bad_triangles.has(triangle))
# 		triangulation = no_bad_triangles
		
# 		for edge in polygon:
# 			var triangle = Triangle.new(point, edge.point_a, edge.point_b)
# 			triangulation.append(triangle)
	
# 	triangulation = triangulation.filter(func(triangle): return !triangle.has_vertex_from(super_triangle))
	
# 	return triangulation

# =======
# CLASSES
# =======

# Define a Point class to represent the coordinates
class Point:
	var x: float
	var y: float

	func _init(x: float, y: float):
		self.x = x
		self.y = y

# ====
# MAIN
# ====

# A triangle is simply an array of three points (Point Objects)
func do_triangulation(points: Array) -> Array:
	# full of triangles
	var triangulation := []

	# Create a "super triangle" that contains all the points
	var superTriangle := createSuperTriangle(points)

	# Add the super triangle to the triangulation
	triangulation.append(superTriangle)

	# Iterate over each point in the set
	for point in points:
		# Find the triangles that are no longer valid due to the new point
		var invalidTriangles := []
		for triangle in triangulation:
			if pointInCircumcircle(point, triangle):
				invalidTriangles.append(triangle)

		# Find the polygon formed by the edges of the invalid triangles
		var polygon := []
		for triangle in invalidTriangles:
			# loop through points of the triangle first
			for vertex in triangle:
				# get the point next in the triangle, or get the first in the triangle
				var vertex_index = triangle.find(vertex)
				var next_vertex_index = vertex_index + 1
				if next_vertex_index >= triangle.size():
					next_vertex_index = 0
				
				# define an edge as an array two points of the triangle
				var edge = [vertex, triangle[next_vertex_index]]
				if not edgeSharedByTriangles(edge, invalidTriangles):
					polygon.append(edge)

		# Remove the invalid triangles from the triangulation
		for triangle in invalidTriangles:
			triangulation.erase(triangle)

		# Create new triangles by connecting the new point with the polygon edges
		# loop through points of the polygon first
		for vertex in polygon:
			# get the point next in the triangle, or get the first in the triangle
			var vertex_index = polygon.find(vertex)
			var next_vertex_index = vertex_index + 1
			if next_vertex_index >= polygon.size():
				next_vertex_index = 0
			
			# define an edge as an array two points of the triangle
			var edge = [vertex, polygon[next_vertex_index]]

			var newTriangle := [edge[0], edge[1], point]
			triangulation.append(newTriangle)

	# Remove any triangles that contain vertices of the super triangle
	triangulation = removeSuperTriangle(triangulation, superTriangle)

	return triangulation

# =======
# HELPERS
# =======

# Create a super triangle that contains all the points
func createSuperTriangle(points: Array) -> Array:
	# Calculate the bounding box of the points
	var minX = points[0].x
	var minY = points[0].y
	var maxX = minX
	var maxY = minY

	for point in points:
		if point.x < minX:
			minX = point.x
		if point.y < minY:
			minY = point.y
		if point.x > maxX:
			maxX = point.x
		if point.y > maxY:
			maxY = point.y

	# Create a super triangle that bounds the points
	var dx = maxX - minX
	var dy = maxY - minY
	var deltaMax = max(dx, dy)
	var midX = (minX + maxX) / 2
	var midY = (minY + maxY) / 2
	
	# just select a random triangle containing all points
# 	var point_1 = Vector2(x_min - dx - 1, y_min - 1)
# 	var point_2 = Vector2(x_min + dx, y_max + (y_max - y_min) + 1)
# 	var point_3 = Vector2(x_max + dx + 1, y_min - 1)

	var superTriangle := [
		Point.new(minX - deltaMax - 1, minY - 1),
		Point.new(minX + deltaMax, maxY + (maxY - minY) + 1),
		Point.new(maxX + deltaMax + 1, minY - 1)
	]

	return superTriangle

# Check if a point is inside the circumcircle of a triangle
func pointInCircumcircle(point: Point, triangle: Array) -> bool:
	var ax = triangle[0].x
	var ay = triangle[0].y
	var bx = triangle[1].x
	var by = triangle[1].y
	var cx = triangle[2].x
	var cy = triangle[2].y

	var d = (ax - point.x) * (by - point.y) - (bx - point.x) * (ay - point.y)
	var e = (bx - point.x) * (cy - point.y) - (cx - point.x) * (by - point.y)
	var f = (cx - point.x) * (ay - point.y) - (ax - point.x) * (cy - point.y)

	return (d >= 0 and e >= 0 and f >= 0) or (d <= 0 and e <= 0 and f <= 0)

# Check if an edge is shared by any of the triangles in the set
func edgeSharedByTriangles(edge: Array, triangles: Array) -> bool:
	for triangle in triangles:
		if edge[0] in triangle and edge[1] in triangle:
			return true
	return false

# Remove triangles that contain vertices of the super triangle
func removeSuperTriangle(triangulation: Array, superTriangle: Array) -> Array:
	var cleanTriangulation := Array()

	for triangle in triangulation:
		if not (triangle[0] in superTriangle or triangle[1] in superTriangle or triangle[2] in superTriangle):
			cleanTriangulation.append(triangle)

	return cleanTriangulation
