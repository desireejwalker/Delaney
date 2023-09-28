class_name Kruskal extends Resource

var minimum_spanning_tree
var edges
var points

var parents

func _init():
	minimum_spanning_tree = []
	edges = []
	points = []
	
	parents = {}
	
func find_minimum_spanning_tree(triangulation) -> Array:
	minimum_spanning_tree = []
	
	edges = []
	points = []
	for triangle in triangulation:
		points.append(triangle.point_a)
		points.append(triangle.point_b)
		points.append(triangle.point_c)
		
		edges.append_array(triangle.edges)
	
	edges.sort_custom(Edge.length_comparison)
	
	parents = {}
	for point in points:
		parents[point] = point
		
	for edge in edges:
		var point_x = union_find(edge.point_a)
		var point_y = union_find(edge.point_b)
		if point_x != point_y:
			minimum_spanning_tree.append(edge)
			parents[point_x] = point_y
			
	return minimum_spanning_tree

func union_find(point):
	if parents[point] != point:
		parents[point] = union_find(parents[point]);
	return parents[point]
