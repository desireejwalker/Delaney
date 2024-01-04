class_name Triangle

var point_a: Vector2
var point_b: Vector2
var point_c: Vector2

var edges: Array[Edge]

var circum_center_x
var circum_center_y
var circum_radius_squared

func _init(point_a: Vector2, point_b: Vector2, point_c: Vector2):
	# hashing depends on the ordering of points a b and c
	if (point_a < point_b):
		if (point_b < point_c):
			# point_a, point_b, point_c
			self.point_a = point_a
			self.point_b = point_b
			self.point_c = point_c
		elif (point_a < point_c):
			# point_a, point_c, point_b
			self.point_a = point_a
			self.point_b = point_c
			self.point_c = point_b
		else:
			# point_c, point_a, point_b
			self.point_a = point_c
			self.point_b = point_a
			self.point_c = point_b
	elif (point_a < point_c):
		# point_b, point_a, point_c
		self.point_a = point_b
		self.point_b = point_a
		self.point_c = point_c
	elif (point_b < point_c):
		# point_b, point_c, point_a
		self.point_a = point_b
		self.point_b = point_c
		self.point_c = point_a
	else:
		# point_c, point_b, point_a
		self.point_a = point_c
		self.point_b = point_a
		self.point_c = point_b
	
	edges = [
		Edge.new(self.point_a, self.point_b),
		Edge.new(self.point_b, self.point_c),
		Edge.new(self.point_a, self.point_c)
	]
	
	var D = (self.point_a.x * (self.point_b.y - self.point_c.y) + self.point_b.x * (self.point_c.y - self.point_a.y) + self.point_c.x * (self.point_a.y - self.point_b.y)) * 2
	var x = (self.point_a.x * self.point_a.x + self.point_a.y * self.point_a.y) * (self.point_b.y - self.point_c.y) + (self.point_b.x * self.point_b.x + self.point_b.y * self.point_b.y) * (self.point_c.y - self.point_a.y) + (self.point_c.x * self.point_c.x + self.point_c.y * self.point_c.y) * (self.point_a.y - self.point_b.y)
	var y = (self.point_a.x * self.point_a.x + self.point_a.y * self.point_a.y) * (self.point_c.x - self.point_b.x) + (self.point_b.x * self.point_b.x + self.point_b.y * self.point_b.y) * (self.point_a.x - self.point_c.x) + (self.point_c.x * self.point_c.x + self.point_c.y * self.point_c.y) * (self.point_b.x - self.point_a.x)
	
	circum_center_x = x / D
	circum_center_y = y / D
	
	var dx = point_a.x - circum_center_x
	var dy = point_a.y - circum_center_y
	circum_radius_squared = dx * dx + dy * dy

func equals(other):
	return (other is Triangle and point_a == other.point_a and point_b == other.point_b and point_c == other.point_c)

func has_edge(edge):
	return edges.has(edge)

func has_vertex(point):
	return (point_a == point or point_b == point or point_c == point)

func has_vertex_from(triangle):
	return (has_vertex(triangle.point_a) or has_vertex(triangle.point_b) or has_vertex(triangle.point_c))

func circum_circle_contains(point):
	var dx = point.x - circum_center_x
	var dy = point.y - circum_center_y
	var distance_squared = dx * dx + dy * dy
	return distance_squared < circum_radius_squared
