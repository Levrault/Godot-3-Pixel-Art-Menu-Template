# Singleton that manage values save
# How to create a new config interface
#	- Add futur options to _engine_default_values
#	- Create a new inherited scene from OptionLayout
#	- Add content field
extends Node

const CONFIG_FILE_PATH := "user://config.cfg"

var _engine_default_values := {}
var _file := ConfigFile.new()

var values := {}


# Find and load config.cfg file
# If not, create a new config file with default value
func _init() -> void:
	_engine_default_values = EngineSettings.get_default()
	var err = _file.load(CONFIG_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found, create a new file with default values" % [CONFIG_FILE_PATH])
		save_file(_engine_default_values)
		load_file()
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [CONFIG_FILE_PATH, err])
		return
	load_file()
	sync_with_new_settings(_engine_default_values)


# Save data
# @param {Dictionary} new data - see _engine_default_values from struc
func save_file(new_settings: Dictionary) -> void:
	for section in new_settings.keys():
		for key in new_settings[section]:
			_file.set_value(section, key, new_settings[section][key])

			if not values.has(section):
				values[section] = {}
			values[section][key] = new_settings[section][key]

	_file.save(CONFIG_FILE_PATH)
	Events.emit_signal("config_file_saved")
	Events.emit_signal("notification_started", "ui_data_saved", Vector2(460, 40))


# Load data from config.cfg
func load_file() -> void:
	for section in _file.get_sections():
		values[section] = {}
		for key in _file.get_section_keys(section):
			values[section][key] = _file.get_value(
				section, key, _engine_default_values[section][key]
			)
	print_debug("%s has been loaded" % [CONFIG_FILE_PATH])


# Update Config.values to by sync with
# engine.cfg file
func sync_with_new_settings(new_settings: Dictionary) -> void:
	for section in new_settings.keys():
		for key in new_settings[section]:
			if not values.has(section):
				values[section] = {}
			if values[section].has(key):
				continue
			values[section][key] = new_settings[section][key]
	save_file(values)


# Update an action InputMap
# @param {String} action_name
# @param {int} scancode
func change_action_key(action_name: String, scancode: int) -> void:
	erase_action_events(action_name)

	var new_event = InputEventKey.new()
	new_event.set_scancode(scancode)
	InputMap.action_add_event(action_name, new_event)


# Delete an action from InputMap
# @param {String} action_name
func erase_action_events(action_name: String) -> void:
	var input_events = InputMap.get_action_list(action_name)
	for event in input_events:
		if event is InputEventKey:
			InputMap.action_erase_event(action_name, event)
