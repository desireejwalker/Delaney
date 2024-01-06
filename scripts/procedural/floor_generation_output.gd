class_name FloorGenerationOutput

var _average_room_size: float
var _room_array: Array[Room]
var _hub_room_array: Array[Room]
var _sub_room_array: Array[Room]
var _paths_array: Array[Rect2i]

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
