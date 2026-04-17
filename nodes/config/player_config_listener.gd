# class_name PlayerConfigListener
# extends PlayerConfig
# ## Helper class for listening to changes within [PlayerConfig].

# static var file_saved: Signal = StaticSignal.make()
# static var file_loaded: Signal = StaticSignal.make() 

# static var config_set: Signal = StaticSignal.make()
# static var config_section_erased: Signal = StaticSignal.make() 
# static var config_section_key_erased: Signal = StaticSignal.make()

# static func _save_config_file() -> void:
# 	var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
# 	if save_error:
# 		push_error("save config file failed with error %d" % save_error)
# 		return
# 	print("file saved")
# 	file_saved.emit()

# static func load_config_file() -> void:
# 	if config_file != null:
# 		return
# 	config_file = ConfigFile.new()
# 	var load_error : int = config_file.load(CONFIG_FILE_LOCATION)
# 	if load_error:
# 		var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
# 		if save_error:
# 			push_error("save config file failed with error %d" % save_error)

# static func set_config(section: String, key: String, value) -> void:
# 	load_config_file()
# 	config_file.set_value(section, key, value)
# 	_save_config_file()

# static func get_config(section: String, key: String, default = null) -> Variant:
# 	load_config_file()
# 	return config_file.get_value(section, key, default)

# static func erase_section(section: String) -> void:
# 	if has_section(section):
# 		config_file.erase_section(section)
# 		_save_config_file()

# static func erase_section_key(section: String, key: String) -> void:
# 	if has_section_key(section, key):
# 		config_file.erase_section_key(section, key)
# 		_save_config_file()