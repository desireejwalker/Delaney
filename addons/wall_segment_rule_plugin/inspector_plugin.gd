extends EditorInspectorPlugin

func _can_handle(object):
	return object is TileSet

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	print(object, type, name, hint_type, hint_string, usage_flags, wide)
	
	if name != "tile_size":
		return
	
	var label = Label.new()
	label.text = "Hello, World!"
	add_custom_control(label)

#func _parse_group(object, group):
	#print(group)
	#var label = Label.new()
	#label.text = "Hello, World!"
	#add_custom_control(label)
