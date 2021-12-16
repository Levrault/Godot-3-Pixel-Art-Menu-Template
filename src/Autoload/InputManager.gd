# Based on https://github.com/nathanhoad/godot_input_helper/blob/main/input_helper/input_helper.gd
extends Node

signal device_changed(device, device_index)

const DEVICE_KEYBOARD := "keyboard"
const DEVICE_XBOX_CONTROLLER := "xbox"
const DEVICE_SWITCH_CONTROLLER := "nintendo"
const DEVICE_PLAYSTATION_CONTROLLER := "dualshock"
const DEVICE_GENERIC := "generic"
const GAMEPAD_MOTION_REGEX := "_AXIS_|_ANALOG_"

var gamepad_button_regex := {
	"xbox": "_XBOX_",
	"nintendo": "_DS_",
	"dualshock": "_SONY_"
}

var device: String = DEVICE_GENERIC
var device_index: int = -1
var _motion_regex := RegEx.new()


func _ready() -> void:
	_motion_regex.compile(GAMEPAD_MOTION_REGEX)


func _input(event: InputEvent) -> void:
	var next_device: String = device
	var next_device_index: int = device_index

	# Did we just press a key on the keyboard?
	if event is InputEventKey and event.is_pressed():
		next_device = DEVICE_KEYBOARD
		next_device_index = -1

	# Did we just use a gamepad?
	if (
		(event is InputEventJoypadButton and event.is_pressed())
		or (event is InputEventJoypadMotion and event.axis_value > 0.1)
	):
		next_device = get_simplified_device_name(Input.get_joy_name(event.device))
		next_device_index = event.device

	if next_device != device or next_device_index != device_index:
		device = next_device
		device_index = next_device_index
		emit_signal("device_changed", device, device_index)


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


func guess_device_name() -> String:
	var connected_joypads = Input.get_connected_joypads()
	if connected_joypads.size() == 0:
		return DEVICE_KEYBOARD
	return get_simplified_device_name(Input.get_joy_name(0))


func is_motion_event(value: String) -> bool:
	return _motion_regex.search(value) != null
