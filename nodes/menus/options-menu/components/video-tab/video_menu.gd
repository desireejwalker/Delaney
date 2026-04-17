extends "res://addons/maaacks_menus_template/base/nodes/menus/options_menu/video/video_options_menu.gd"

func _preselect_resolution(window : Window) -> void:
	%GameResolutionControl.value = window.size

func _update_resolution_options_enabled(window : Window) -> void:
	if OS.has_feature("web"):
		%GameResolutionControl.editable = false
		%GameResolutionControl.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		%GameResolutionControl.editable = false
		%GameResolutionControl.tooltip_text = "Disabled for fullscreen"
	else:
		%GameResolutionControl.editable = true
		%GameResolutionControl.tooltip_text = "Select a screen size"

func _update_ui(window : Window) -> void:
	# %FullscreenControl.value = AppSettings.is_fullscreen(window)
	_preselect_resolution(window)
	%VSyncControl.value = AppSettings.get_vsync(window)
	_update_resolution_options_enabled(window)
