class_name GameManager extends Node

func _ready():
	var floor_generator = FloorGenerator.new()
	var visualizer = FloorGenerationVisualizer.new(floor_generator)
	
	add_child(floor_generator)
	add_child(visualizer)
	
	floor_generator.run(40)
