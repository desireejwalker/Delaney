class_name PlayerConfig
extends Object

## Interface for a single configuration file through [ConfigFile].

# File Signals

static var file_saved: Signal = StaticSignal.make()
static var file_loaded: Signal = StaticSignal.make() 

# Config Modification Signals

static var config_set: Signal = StaticSignal.make()
static var config_section_erased: Signal = StaticSignal.make() 
static var config_section_key_erased: Signal = StaticSignal.make()

const CONFIG_FILE_LOCATION := "user://player_config.cfg"

static var config_file : ConfigFile

static func _save_config_file() -> void:
	var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
	if save_error:
		push_error("save config file failed with error %d" % save_error)
		return
	file_saved.emit()

static func load_config_file() -> void:
	if config_file != null:
		return
	config_file = ConfigFile.new()
	var load_error : int = config_file.load(CONFIG_FILE_LOCATION)
	if load_error:
		var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
		if save_error:
			push_error("save config file failed with error %d" % save_error)
		return
	file_loaded.emit()

static func set_config(section: String, key: String, value) -> void:
	load_config_file()
	config_file.set_value(section, key, value)
	config_set.emit()
	_save_config_file()

static func get_config(section: String, key: String, default = null) -> Variant:
	load_config_file()
	return config_file.get_value(section, key, default)

static func has_section(section: String) -> bool:
	load_config_file()
	return config_file.has_section(section)

static func has_section_key(section: String, key: String) -> bool:
	load_config_file()
	return config_file.has_section_key(section, key)

static func erase_section(section: String) -> void:
	if has_section(section):
		config_file.erase_section(section)
		config_section_erased.emit()
		_save_config_file()

static func erase_section_key(section: String, key: String) -> void:
	if has_section_key(section, key):
		config_file.erase_section_key(section, key)
		config_section_key_erased.emit()
		_save_config_file()

static func get_section_keys(section: String) -> PackedStringArray:
	load_config_file()
	if config_file.has_section(section):
		return config_file.get_section_keys(section)
	return PackedStringArray()
