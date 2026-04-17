extends "res://addons/maaacks_menus_template/base/nodes/utilities/pause_menu_controller.gd"

@export var menu_renderer: Renderer

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()

func _ready() -> void:
	pause_menu = pause_menu_packed.instantiate()
	pause_menu.hide()
	menu_renderer.sub_viewport.call_deferred("add_child", pause_menu)