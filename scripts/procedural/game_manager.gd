class_name GameManager extends Node

func _ready():
	var floor_generator = FloorGenerator.new()
	add_child(floor_generator)
	
	floor_generator.run(10)
