extends "res://addons/maaacks_menus_template/base/nodes/menus/options_menu/audio/audio_options_menu.gd"

# Option Name

@export_group("Option Name")
@export var option_name_prefix: String
@export var option_name_suffix: String
@export var capitalize_option_name: bool

# Config

@export_group("Config")
@export var config_section_name: StringName

func _add_audio_control(bus_name : String, bus_value : float, bus_iter : int) -> void:
	if audio_control_scene == null or bus_name in hide_busses or bus_name.begins_with(AppSettings.SYSTEM_BUS_NAME_PREFIX):
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is OptionControl:
		audio_control.option_section = OptionControl.OptionSections.AUDIO
		if capitalize_option_name:
			bus_name = bus_name.to_upper()
		audio_control.option_name = option_name_prefix+bus_name+option_name_suffix
		audio_control.value = bus_value

		audio_control.key = bus_name.to_snake_case()
		audio_control.section = config_section_name

		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_iter))