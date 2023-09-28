class_name Edge

var point_a: Vector2
var point_b: Vector2

func _init(point_a: Vector2, point_b: Vector2):
	self.point_a = point_a
	self.point_b = point_b
	
func equals(edge: Edge) -> bool:
	return (point_a == edge.point_a && point_b == edge.point_b) || (point_a == edge.point_b && point_b == edge.point_a)

func length() -> float:
	return point_a.distance_to(point_b)

func center() -> Vector2:
	return (point_a + point_b) * 0.5
	
static func length_comparison(edge_a, edge_b):
	var edge_a_length = edge_a.length()
	var edge_b_length = edge_b.length()
	
	return edge_a_length >= edge_b_length
