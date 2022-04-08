# Detect witch device is currently
# Provide some usefull function about gamepad or keyboard action
# Contains all key icons of all device
# @see https://github.com/nathanhoad/godot_input_helper/blob/main/input_helper/input_helper.gd
extends Node

signal device_changed(device, device_index)

const DEVICE_KEYBOARD := "keyboard"
const DEVICE_MOUSE := "mouse"
const DEVICE_XBOX_CONTROLLER := "xbox"
const DEVICE_SWITCH_CONTROLLER := "nintendo"
const DEVICE_PLAYSTATION_CONTROLLER := "dualshock"
const DEVICE_GENERIC := "generic"
const GAMEPAD_MOTION_REGEX := "_AXIS_|_ANALOG_"
const ICON_ATLAS_TEXTURE_PATH := "res://assets/ui/icons/input_icons_atlas_texture.png"

var all_gamepad_devices := [
	DEVICE_XBOX_CONTROLLER,
	DEVICE_SWITCH_CONTROLLER,
	DEVICE_PLAYSTATION_CONTROLLER,
	DEVICE_GENERIC
]

var atlas_map := {}
var default_gamepad: String = DEVICE_XBOX_CONTROLLER
var device: String = default_gamepad setget _set_device
var device_index: int = -1
var gamepad_button_regex := {"xbox": "_XBOX_", "nintendo": "_DS_", "dualshock": "_SONY_", "generic": "_BUTTON_"}

var _motion_regex := RegEx.new()


func _ready() -> void:
	atlas_map = EngineSettings.get_icon_atals_map()
	_motion_regex.compile(GAMEPAD_MOTION_REGEX)


# Based on the current input, will update wich device is used
func _input(event: InputEvent) -> void:
	var next_device: String = device
	var next_device_index: int = device_index

	# keyboard
	if event is InputEventKey and event.is_pressed():
		next_device = DEVICE_KEYBOARD
		next_device_index = -1

	# mouse
	if (event is InputEventMouseButton and event.is_pressed()) or event is InputEventMouseMotion:
		next_device = DEVICE_MOUSE
		next_device_index = -1

	# gamepad
	if (
		(event is InputEventJoypadButton and event.is_pressed())
		or (event is InputEventJoypadMotion and event.axis_value > 0.1)
	):
		next_device = get_simplified_device_name(Input.get_joy_name(event.device))
		next_device_index = event.device

	if next_device != device or next_device_index != device_index:
		self.device = next_device
		device_index = next_device_index
		emit_signal("device_changed", device, device_index)


# Utils function to quickly add a motion event
func addJoyMotionEvent(action: String, value: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event_motion = InputEventJoypadMotion.new()
	input_event_motion.axis = EngineSettings.keylist.gamepad[value]
	InputMap.action_add_event(action, input_event_motion)


# Utils function to quickly remove a motion event
func removeJoyMotionEvent(action: String, value: String) -> void:
	if not InputMap.has_action(action):
		return
	var input_event_motion = InputEventJoypadMotion.new()
	input_event_motion.axis = EngineSettings.keylist.gamepad[value]
	InputMap.action_erase_event(action, input_event_motion)


# Utils function to quickly add a motion event with axis_value
func addJoyStickMotionEvent(action: String, value: String, axis_value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event_motion = InputEventJoypadMotion.new()
	input_event_motion.axis = EngineSettings.keylist.gamepad[value]
	input_event_motion.axis_value = axis_value
	InputMap.action_add_event(action, input_event_motion)


# Utils function to quickly remove a motion event with axis_value
func removeJoyStickMotionEvent(action: String, value: String, axis_value: float) -> void:
	if not InputMap.has_action(action):
		return
	var input_event_motion = InputEventJoypadMotion.new()
	input_event_motion.axis = EngineSettings.keylist.gamepad[value]
	input_event_motion.axis_value = axis_value
	InputMap.action_erase_event(action, input_event_motion)


# Utils function to add a joy button event
func addJoyButtonEvent(action: String, value: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event_button = InputEventJoypadButton.new()
	input_event_button.button_index = EngineSettings.keylist.gamepad[value]
	InputMap.action_add_event(action, input_event_button)


# Utils function to remove a joy button event
func removeJoyButtonEvent(action: String, value: String) -> void:
	if not InputMap.has_action(action):
		return
	var input_event_button = InputEventJoypadButton.new()
	input_event_button.button_index = EngineSettings.keylist.gamepad[value]
	InputMap.action_erase_event(action, input_event_button)


# return a understable device name
func get_simplified_device_name(raw_name: String) -> String:
	match raw_name:
		"XInput Gamepad", "Xbox Series Controller":
			return DEVICE_XBOX_CONTROLLER
		"PS5 Controller", "PS4 Controller", "PS3 Controller", "PS2 Controller":
			return DEVICE_PLAYSTATION_CONTROLLER
		"Switch":
			return DEVICE_SWITCH_CONTROLLER
		_:
			return DEVICE_GENERIC


func is_using_gamepad() -> bool:
	var result := false
	for gamepad_device in all_gamepad_devices:
		if device == gamepad_device:
			result = true
	return result


func is_motion_event(value: String) -> bool:
	return _motion_regex.search(value) != null


# return the global scope variable name from a action/device
func get_device_button_from_action(action: String, for_device: String) -> String:
	if not InputMap.has_action(action):
		printerr("Action %s does not exist" % action)
		return ""
	var result := ""
	for evt in InputMap.get_action_list(action):
		if for_device == DEVICE_KEYBOARD or for_device == DEVICE_MOUSE:
			if evt is InputEventKey:
				return OS.get_scancode_string(evt.scancode)
		else:
			if evt is InputEventJoypadButton:
				return EngineSettings.get_gamepad_button_from_joy_string(
					evt.button_index, Input.get_joy_button_string(evt.button_index), for_device
				)
	printerr("Not key were for found for %s on device %s" % [action, for_device])
	return result


func get_device_icon_texture_from_action(input: String, for_device: String, alt := false) -> AtlasTexture:
	if for_device == InputManager.DEVICE_MOUSE:
		for_device = InputManager.DEVICE_KEYBOARD
	if for_device == InputManager.DEVICE_KEYBOARD:
		input = "KEY_" + input.to_upper()

	if alt:
		for_device += "_alt"

	if not atlas_map.has(for_device) or not atlas_map[for_device].has(input):
		return null

	var texture = AtlasTexture.new()
	texture.atlas = load(ICON_ATLAS_TEXTURE_PATH)
	var atlas_region = atlas_map[for_device][input]
	texture.region = Rect2(atlas_region[0], atlas_region[1], atlas_region[2], atlas_region[3])

	return texture


func get_device_icon_texture_fallback(for_device: String) -> AtlasTexture:
	if for_device == InputManager.DEVICE_MOUSE:
		for_device = InputManager.DEVICE_KEYBOARD

	var texture = AtlasTexture.new()
	texture.atlas = load(ICON_ATLAS_TEXTURE_PATH)

	var atlas_region = atlas_map["fallback"]["TEMPLATE"]
	texture.region = Rect2(atlas_region[0], atlas_region[1], atlas_region[2], atlas_region[3])

	return texture


func _set_device(value: String) -> void:
	device = value

	if device == DEVICE_KEYBOARD or device == DEVICE_MOUSE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
