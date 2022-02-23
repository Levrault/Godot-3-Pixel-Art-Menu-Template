# Manage user's settings
# Sync with engine.cfg settings
# Save/load, create user settings
# @category: Autoload
extends Node

# save file path
const CONFIG_FILE_PATH := "user://config.cfg"

# values of config.cfg
var values := {}
var is_new := false

var _file := ConfigFile.new()


# Find and load config.cfg file
# if not, create a new config file with default engine values
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


# Create a new file
func create_file(new_settings: Dictionary) -> void:
	for section in new_settings.keys():
		for key in new_settings[section]:
			_file.set_value(section, key, new_settings[section][key])

			if not values.has(section):
				values[section] = {}
			values[section][key] = new_settings[section][key]

	is_new = true
	_file.save(CONFIG_FILE_PATH)
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("File has been saved")


# Save all user data
func save_file(settings: Dictionary) -> void:
	_file.clear()
	for section in settings.keys():
		for key in settings[section]:
			_file.set_value(section, key, settings[section][key])

	_file.save(CONFIG_FILE_PATH)
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("File has been saved")


# Save a section
func save_section(section: String, data: Dictionary) -> void:
	for key in data:
		_file.set_value(section, key, data[key])
	_file.save(CONFIG_FILE_PATH)
	values[section] = data.duplicate()
	Events.call_deferred("emit_signal", "config_file_saved")
	print_debug("File has been saved")


# Save a field
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
	Events.emit_signal("config_file_loaded")
	print_debug("%s has been loaded" % [CONFIG_FILE_PATH])


# Assure that both config.cfg and engine.cfg are synched
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
		for key in values[section].keys():
			if not engine_settings.has(section):
				values.erase(section)
				continue
			if not engine_settings[section].has(key):
				values[section].erase(key)

	# remove depreciated keyboard binding
	for key in values.keyboard_and_mouse_bindind.keys():
		if not engine_settings.keyboard_and_mouse_bindind.has(key):
			values.keyboard_and_mouse_bindind.erase(key)

	# remove depreciated gamepad binding
	for section in values.gamepad_bindind.keys():
		if not engine_settings.gamepad_bindind.has(section):
			values.gamepad_bindind.erase(section)
			continue

		for key in values.gamepad_bindind[section].keys():
			if not engine_settings.gamepad_bindind[section].has(key):
				values.gamepad_bindind[section].erase(key)

	# add new values (only needed for gamepad, keyboard do it on his own)
	for section in engine_settings.gamepad_bindind.keys():
		if not values.gamepad_bindind.has(section):
			values.gamepad_bindind = {}

		for key in engine_settings.gamepad_bindind[section].keys():
			if not values.gamepad_bindind[section].has(key):
				values.gamepad_bindind[section][key] = engine_settings.gamepad_bindind[section][key]

	save_file(values)
