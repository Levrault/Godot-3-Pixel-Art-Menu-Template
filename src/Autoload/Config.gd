# Singleton that manage values save
extends Node

const CONFIG_FILE_PATH := "user://config.cfg"

var _file := ConfigFile.new()
var values := {}


# Find and load config.cfg file
# If not, create a new config file with default value
func _init() -> void:
	var err = _file.load(CONFIG_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found, create a new file with default values" % [CONFIG_FILE_PATH])
		create_file(EngineSettings.default)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [CONFIG_FILE_PATH, err])
		return
	load_file()
	sync_with_engine_settings()


# Clear and save file
# @param {Dictionary} new data - see EngineSettings.default from struc
func create_file(new_settings: Dictionary) -> void:
	for section in new_settings.keys():
		for key in new_settings[section]:
			_file.set_value(section, key, new_settings[section][key])

			if not values.has(section):
				values[section] = {}
			values[section][key] = new_settings[section][key]

	_file.save(CONFIG_FILE_PATH)
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("File has been saved")


# Clear and save file
# @param {Dictionary} new data - see EngineSettings.default from struc
func save_file(settings: Dictionary) -> void:
	_file.clear()
	for section in settings.keys():
		for key in settings[section]:
			_file.set_value(section, key, settings[section][key])

	_file.save(CONFIG_FILE_PATH)
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("File has been saved")


func save_section(section: String, values: Dictionary) -> void:
	for key in values:
		_file.set_value(section, key, values[key])

	_file.save(CONFIG_FILE_PATH)
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("File has been saved")


func save_field(section: String, field: String, value) -> void:
	_file.set_value(section, field, value)
	_file.save(CONFIG_FILE_PATH)
	values[section][field] = _file.get_value(section, field, value)
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("%s/%s has been saved with %s" % [section, field, value])


# Load data from config.cfg
func load_file() -> void:
	for section in _file.get_sections():
		values[section] = {}
		for key in _file.get_section_keys(section):
			var default_variant = null

			if EngineSettings.default.has(section):
				default_variant = EngineSettings.default[section].get(key)

			values[section][key] = _file.get_value(section, key, default_variant)
	print_debug("%s has been loaded" % [CONFIG_FILE_PATH])


# Update Config.values to by sync with
# engine.cfg file
func sync_with_engine_settings() -> void:
	var engine_settings: Dictionary = EngineSettings.default.duplicate()
	# sync new values
	for section in engine_settings.keys():
		for key in engine_settings[section]:
			if not values.has(section):
				values[section] = {}
			if values[section].has(key):
				continue
			values[section][key] = engine_settings[section][key]

	# remove depreciated values
	for section in values.keys():
		for key in values[section]:
			if not engine_settings.has(section):
				values.erase(section)
				continue
			if not engine_settings[section].has(key):
				print(key)
				values[section].erase(key)
				print(values[section])
				
	print(values)
	save_file(values)
