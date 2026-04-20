extends MainMenu

@export var how_to_play_packed_scene : PackedScene

func _on_how_to_play_button_pressed() -> void:
	_open_sub_menu(how_to_play_packed_scene)
