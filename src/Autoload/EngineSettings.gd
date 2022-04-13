# Read all engine configuration file
#
# engine.cfg, engine_override_osx.cfg, engine_override_x11.cfg
# contains all configurable fields and their call back action
#
# keylist.cfg
# provide a readable key (and gamepad) event system
# e.g. KEY_ESCAPE = 16777217 ; Escape key.
#
# keyboard.cfg
# contains all differents key input for every supported
# keyboard layout (qwerty, azerty)
#
# keyboard_ui.cfg
# contains all differents ui  key input for every supported
# keyboard layout (qwerty, azerty)
#
# gamepad.cfg
# contains all differents gamepad input for every supported
# gamepad supported (xbox, nintendo, sony, generic)
extends Node

const DEFAULT_KEYBOARD := "qwerty"
const ENGINE_FILE_PATH := "res://engine/engine.cfg"
const ENGINE_FILE_PATH_OSX := "res://engine/engine_override_osx.cfg"
const ENGINE_FILE_PATH_X11 := "res://engine/engine_override_x11.cfg"
const KEYBOARD_FILE_PATH := "res://engine/keyboard.cfg"
const KEYBOARD_UI_FILE_PATH := "res://engine/keyboard_ui.cfg"
const GAMEPAD_FILE_PATH := "res://engine/gamepad.cfg"
const KEYLIST_FILE_PATH := "res://engine/keylist.cfg"
const ICON_ATLAS_MAP_FILE_PATH := "res://engine/input_icons_atlas_map.cfg"

# workaround to map mouse input to translation key
const MOUSE_INDEX_TO_STRING := {
	"BUTTON_LEFT": "mouse.left_mouse_button",
	"BUTTON_RIGHT": "mouse.right_mouse_button",
	"BUTTON_MIDDLE": "mouse.middle_mouse_button",
	"BUTTON_XBUTTON1": "mouse.mouse_xbutton1",
	"BUTTON_XBUTTON2": "mouse.mouse_xbutton2",
	"BUTTON_WHEEL_UP": "mouse.wheel_up_mouse_button",
	"BUTTON_WHEEL_DOWN": "mouse.wheel_down_mouse_button",
	"BUTTON_WHEEL_LEFT": "mouse.wheel_left_mouse_button",
	"BUTTON_WHEEL_RIGHT": "mouse.wheel_right_mouse_button",
	"BUTTON_MASK_LEFT": "mouse.mask_left_mouse_button",
	"BUTTON_MASK_RIGHT": "mouse.mask_right_mouse_button",
	"BUTTON_MASK_MIDDLE": "mouse.mask_middle_mouse_button",
	"BUTTON_MASK_XBUTTON1": "mouse.mask_xbutton1_mouse_button",
	"BUTTON_MASK_XBUTTON2": "mouse.mask_xbutton2_mouse_button"
}

var gamepad_regex := {"xbox": "_XBOX_", "nintendo": "_DS_", "dualshock": "_SONY_"}

# contains data of all .cfg file from engine folder
var data := {}
# all default field value from engine.cfg
var default := {}
# keyboard input
var keyboard := {}
# gamepad input
var gamepad := {}
# readable keylist
var keylist := {}


func _init() -> void:
	_read_engine_file()

	if OS.get_name() == "OSX":
		_override_engine_file(ENGINE_FILE_PATH_OSX)
	elif OS.get_name() == "X11":
		_override_engine_file(ENGINE_FILE_PATH_X11)
	_read_keylist_file()
	_read_keyboard_file()
	_read_gamepad_file()
	_read_keyboard_ui_file()

	default = get_default()


# return the option list for a specific field (Section > Key) of engine.cfg
func get_option(section: String, key: String, value: String) -> Dictionary:
	var result := {}
	for option in data[section][key].options:
		if option.key != value:
			continue
		result = option

	return result


# return properties for a specific field (Section > Key) of engine.cfg
func get_properties(section: String, key: String, value: String) -> Dictionary:
	var result := {}
	for properties in data[section][key].properties:
		if properties.key != value:
			continue
		result = properties

	return result


# return all default value of every fields of engine.cfg
func get_default() -> Dictionary:
	var result := {}
	for section in data:
		result[section] = {}
		for key in data[section]:
			result[section][key] = data[section][key]["default"]

	result["keyboard_and_mouse_bindind"] = get_keyboard_or_mouse_key_from_keyboard_variant()
	result["gamepad_bindind"] = get_gamepad_layout()
	return result


func get_keyboard_or_mouse_key_from_keyboard_variant() -> Dictionary:
	print_debug("The keyboard is a %s" % OS.get_latin_keyboard_variant())
	var keyboard_scheme := {}
	if keyboard.has(OS.get_latin_keyboard_variant()):
		keyboard_scheme = keyboard[OS.get_latin_keyboard_variant().to_lower()]
	else:
		keyboard_scheme = keyboard[DEFAULT_KEYBOARD].duplicate()
	return keyboard_scheme


# return the corresponding event of keylist.cfg
func get_keyboard_or_mouse_key_from_scancode(scancode: int) -> String:
	for key in keylist.keyboard:
		if keylist.keyboard[key] == scancode:
			return key

	for key in keylist.mouse:
		if keylist.mouse[key] == scancode:
			return key
	return ""


func get_gamepad_layout() -> Dictionary:
	var result := {}
	for section in gamepad:
		result[section] = gamepad[section]["default"]
	return result


# return the matching event of keylist.cfg based on the joy_string and gamepad type
func get_gamepad_button_from_joy_string(value: int, joy_string := "", type := "") -> String:
	var device = InputManager.gamepad_button_regex[type]
	var result := ""
	for key in keylist.gamepad:
		var key_joy_string := (
			Input.get_joy_axis_string(keylist.gamepad[key])
			if InputManager.is_motion_event(key)
			else Input.get_joy_button_string(keylist.gamepad[key])
		)
		if key_joy_string == joy_string and keylist.gamepad[key] == value:
			# for gamepad specific button
			if value in range(0, 4) and device in key:
				return key
			result = key
	return result


# return the mouse translation key
func get_mouse_button_string(key: String) -> String:
	return MOUSE_INDEX_TO_STRING[key]


func get_icon_atals_map() -> Dictionary:
	var atlas_map := {}
	var atlas_map_file := ConfigFile.new()
	var err = atlas_map_file.load(ICON_ATLAS_MAP_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("engine.cfg has not been found at %s" % ICON_ATLAS_MAP_FILE_PATH)
		return {}
	if err != OK:
		print_debug("%s has encounter an error: %s" % [ICON_ATLAS_MAP_FILE_PATH, err])
		return {}

	for section in atlas_map_file.get_sections():
		atlas_map[section] = {}
		for key in atlas_map_file.get_section_keys(section):
			atlas_map[section][key] = atlas_map_file.get_value(section, key)

	return atlas_map


func _read_engine_file() -> void:
	var engine_file := ConfigFile.new()
	var err = engine_file.load(ENGINE_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("engine.cfg has not been found at %s" % ENGINE_FILE_PATH)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [ENGINE_FILE_PATH, err])
		return

	for section in engine_file.get_sections():
		data[section] = {}
		for key in engine_file.get_section_keys(section):
			data[section][key] = engine_file.get_value(section, key)


func _override_engine_file(file_path: String) -> void:
	var file := ConfigFile.new()
	var err = file.load(file_path)
	if err == ERR_FILE_NOT_FOUND:
		printerr("%s has not been found" % file_path)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [file_path, err])
		return

	for section in file.get_sections():
		for key in file.get_section_keys(section):
			if not data.has(section):
				printerr("%s > %s section doesn't exist in engine.cfg" % [file_path, section])
				continue
			data[section][key] = file.get_value(section, key)


func _read_keylist_file() -> void:
	var keylist_file := ConfigFile.new()
	var err = keylist_file.load(KEYLIST_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("engine.cfg has not been found at %s" % KEYLIST_FILE_PATH)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [KEYLIST_FILE_PATH, err])
		return

	for section in keylist_file.get_sections():
		keylist[section] = {}
		for key in keylist_file.get_section_keys(section):
			keylist[section][key] = keylist_file.get_value(section, key)


func _read_keyboard_file() -> void:
	var keyboard_file := ConfigFile.new()
	var err = keyboard_file.load(KEYBOARD_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("keyboard.cfg has not been found at %s" % KEYBOARD_FILE_PATH)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [KEYBOARD_FILE_PATH, err])
		return

	for section in keyboard_file.get_sections():
		keyboard[section] = {}
		for key in keyboard_file.get_section_keys(section):
			keyboard[section][key] = keyboard_file.get_value(section, key)


func _read_gamepad_file() -> void:
	var gamepad_file := ConfigFile.new()
	var err = gamepad_file.load(GAMEPAD_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("gamepad.cfg has not been found at %s" % GAMEPAD_FILE_PATH)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [GAMEPAD_FILE_PATH, err])
		return

	for section in gamepad_file.get_sections():
		gamepad[section] = {}
		for key in gamepad_file.get_section_keys(section):
			gamepad[section][key] = gamepad_file.get_value(section, key)


func _read_keyboard_ui_file() -> void:
	if OS.get_latin_keyboard_variant().to_lower() == DEFAULT_KEYBOARD:
		return

	var keyboard_ui_file := ConfigFile.new()
	var err = keyboard_ui_file.load(KEYBOARD_UI_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		printerr("keyboard_ui.cfg has not been found at %s" % KEYBOARD_UI_FILE_PATH)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [KEYBOARD_UI_FILE_PATH, err])
		return

	var keyboard_ui := {}
	for section in keyboard_ui_file.get_sections():
		keyboard_ui[section] = {}
		for key in keyboard_ui_file.get_section_keys(section):
			keyboard_ui[section][key] = keyboard_ui_file.get_value(section, key)

	var keyboard_ui_scheme := {}
	if not keyboard_ui.has(OS.get_latin_keyboard_variant().to_lower()):
		return

	keyboard_ui_scheme = keyboard_ui[OS.get_latin_keyboard_variant().to_lower()]

	# clear default keyboard action
	var default_keyboard_ui_scheme = keyboard_ui[OS.get_latin_keyboard_variant().to_lower()]
	for action in default_keyboard_ui_scheme:
		for key in default_keyboard_ui_scheme[action]:
			if not InputMap.has_action(action):
				continue
			var input_event_key = InputEventKey.new()
			input_event_key.set_scancode(keylist.keyboard[key])
			InputMap.action_erase_event(action, input_event_key)

	# add new action
	for action in keyboard_ui_scheme:
		for key in keyboard_ui_scheme[action]:
			if not InputMap.has_action(action):
				InputMap.add_action(action)
			var input_event_key = InputEventKey.new()
			input_event_key.set_scancode(keylist.keyboard[key])
			InputMap.action_add_event(action, input_event_key)
