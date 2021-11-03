# Read engine.cfg file
extends Node

const FILE_PATH := "res://engine/engine.cfg"

var data := {}
var _file := ConfigFile.new()


func _init() -> void:
	var err = _file.load(FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("Engine.cfg has not been found at %s" % FILE_PATH)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [FILE_PATH, err])
		return

	for section in _file.get_sections():
		data[section] = {}
		for key in _file.get_section_keys(section):
			data[section][key] = _file.get_value(section, key)


func get_option(section: String, key: String, value: String) -> Dictionary:
	var result := {}
	for option in data[section][key].options:
		if option.key != value:
			continue
		result = option

	return result


func get_properties(section: String, key: String, value: String) -> Dictionary:
	var result := {}
	for properties in data[section][key].properties:
		if properties.key != value:
			continue
		result = properties

	return result


func get_default() -> Dictionary:
	var result := {}
	for section in data:
		result[section] = {}
		for key in data[section]:
			result[section][key] = data[section][key]["default"]
	return result
