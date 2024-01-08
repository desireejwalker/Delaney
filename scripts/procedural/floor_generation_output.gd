class_name FloorGenerationOutput

var _average_room_size: float
var _room_array: Array[Room]
var _hub_room_array: Array[Room]
var _sub_room_array: Array[Room]
var _paths_array: Array[Rect2i]

var _floor_graph: Array

func _init(average_room_size: float, room_array: Array[Room], hub_room_array: Array[Room], sub_room_array: Array[Room], paths_array: Array[Rect2i], floor_graph: Array):
	_average_room_size = average_room_size
	_room_array = room_array
	_hub_room_array = hub_room_array
	_sub_room_array = sub_room_array
	_paths_array = paths_array
	
	_floor_graph = floor_graph

func get_average_room_size() -> float:
	return _average_room_size

func get_rooms() -> Array[Room]:
	return _room_array

func get_hub_rooms() -> Array[Room]:
	return _hub_room_array

func get_sub_rooms() -> Array[Room]:
	return _sub_room_array

func get_paths() -> Array[Rect2i]:
	return _paths_array

func get_floor_graph() -> Array:
	return _floor_graph
