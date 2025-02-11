class_name ComboActionEntry extends Resource

@export var name: String
@export var points: int

func _to_string() -> String:
	return "1x " + name + " - " + str(points) + "pts"
