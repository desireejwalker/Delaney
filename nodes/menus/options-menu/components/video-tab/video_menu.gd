extends "res://addons/maaacks_menus_template/base/nodes/menus/options_menu/video/video_options_menu.gd"

func _preselect_resolution(window : Window) -> void:
	%GameResolutionControl.value = AppSettings.get_game_resolution(window)

func _update_resolution_options_enabled(window : Window) -> void:
	pass
	# if OS.has_feature("web"):
	# 	%GameResolutionControl.editable = false
	# 	%GameResolutionControl.tooltip_text = "Disabled for web"
	# elif AppSettings.is_fullscreen(window):
	# 	%GameResolutionControl.editable = false
	# 	%GameResolutionControl.tooltip_text = "Disabled for fullscreen"
	# else:
	# 	%GameResolutionControl.editable = true
	# 	%GameResolutionControl.tooltip_text = "Select a screen size"

func _update_ui(window : Window) -> void:
	_update_screen_mode_control(window)
	_preselect_resolution(window)
	%VSyncControl.value = AppSettings.get_vsync(window)
	_update_resolution_options_enabled(window)

func _update_screen_mode_control(window: Window) -> void:
	var screen_mode = AppSettings.get_screen_mode(window)
	match screen_mode:
		Window.MODE_EXCLUSIVE_FULLSCREEN:
			%ScreenModeControl.value = 2
		Window.MODE_FULLSCREEN:
			%ScreenModeControl.value = 1
		_:
			%ScreenModeControl.value = 0

func _on_screen_mode_control_setting_changed(value: Variant) -> void:
	var window : Window = get_window()
	AppSettings.set_screen_mode(value, window)
	# _update_resolution_options_enabled(window)

func _on_game_resolution_control_setting_changed(value: Variant) -> void:
	AppSettings.set_game_resolution(value, get_window(), false)

func _on_anti_aliasing_control_setting_changed(value: Variant) -> void:
	AppSettings.set_anti_aliasing(value)


func _on_brightness_control_setting_changed(value: Variant) -> void:
	pass # Replace with function body.


func _on_world_resolution_control_setting_changed(value: Variant) -> void:
	pass
