class_name Kruskal

# ==========
# DEPRECATED
# ==========

var minimum_spanning_tree: Array[Edge]
var edges
var points

var parents

func _init():
	minimum_spanning_tree = []
	edges = []
	points = []
	
	parents = {}
	
func find_minimum_spanning_tree(triangulation) -> Array[Edge]:
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

# =======
# CLASSES
# =======

class DisjointSet:
	var parent: Dictionary
	var rank: Dictionary

	func _init(vertices: Array):
		parent = {}
		rank = {}

		for vertex in vertices:
			parent[vertex] = vertex
			rank[vertex] = 0

	func find(vertex):
		if parent[vertex] != vertex:
			parent[vertex] = find(parent[vertex])
		
		return parent[vertex]

	func union(vertexA, vertexB):
		var rootA = find(vertexA)
		var rootB = find(vertexB)

		if rootA != rootB:
			if rank[rootA] < rank[rootB]:
				parent[rootA] = rootB
			elif rank[rootA] > rank[rootB]:
				parent[rootB] = rootA
			else:
				parent[rootB] = rootA
				rank[rootA] += 1

# ====
# MAIN
# ====

# Kruskal's Algorithm for Minimum Spanning Tree
func do_minimum_spanning_tree(vertices: Array, triangulation: Array) -> Array:
	# Initialize the edge list with all the edges in the triangulation
	var edges = Array()
	for triangle in triangulation:
		edges.append([triangle[0], triangle[1]])
		edges.append([triangle[1], triangle[2]])
		edges.append([triangle[2], triangle[0]])

	# Sort the edges in non-decreasing order of their weights
	edges.sort_custom(compareEdges)

	# Create a disjoint set data structure to track the connected components
	var disjointSet := DisjointSet.new(vertices)

	# Initialize the minimum spanning tree
	var minimumSpanningTree := Array()

	# Iterate over each edge in the sorted edge list
	for edge in edges:
		var u = edge[0]
		var v = edge[1]

		# If the edge does not create a cycle, add it to the minimum spanning tree
		if disjointSet.find(u) != disjointSet.find(v):
			minimumSpanningTree.append(edge)
			disjointSet.union(u, v)

	return minimumSpanningTree

# Custom comparison function for sorting edges
func compareEdges(edgeA: Array, edgeB: Array) -> int:
	var weightA := calculateEdgeWeight(edgeA)
	var weightB := calculateEdgeWeight(edgeB)

	if weightA < weightB:
		return -1
	elif weightA > weightB:
		return 1
	else:
		return 0

# Helper function to calculate the weight of an edge
func calculateEdgeWeight(edge: Array) -> float:
	var pointA = edge[0]
	var pointB = edge[1]

	# Calculate the Euclidean distance between the two points
	var dx = pointA.x - pointB.x
	var dy = pointA.y - pointB.y
	return sqrt(dx * dx + dy * dy)
