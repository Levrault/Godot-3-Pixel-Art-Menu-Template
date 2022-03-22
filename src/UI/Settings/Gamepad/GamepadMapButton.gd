# Gamepad button
# Trigger bindind action when pressed
# Use by GamepadMapField
# @category: Gamepad, Rebind
extends Button

export var key := ""

# Global constant joystick value e.g. JOY_XBOX_B
var assigned_to := ""
# equivalent name as a string return by input class get_joy_x function 
var joy_string := ""
# gamepad type (xbox, dualshock, nintendo)
var type := "xbox"


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")
	type = InputManager.default_gamepad


# assign a new value based on a constant string from keylist.cfg
func assign_with_constant(value: String) -> void:
	clear()
	assigned_to = value
	text = assigned_to

	if InputManager.is_motion_event(value):
		joy_string = Input.get_joy_axis_string(EngineSettings.keylist.gamepad[value])
		InputManager.addJoyMotionEvent(owner.action, value)
	else:
		joy_string = Input.get_joy_button_string(EngineSettings.keylist.gamepad[value])
		InputManager.addJoyButtonEvent(owner.action, value)
		
	icon = InputManager.get_device_icon_texture_from_action(value, type)
	owner.values[key] = {
		joy_value = EngineSettings.keylist.gamepad[assigned_to],
		device_joy_string = assigned_to,
		joy_string = joy_string
	}


func clear() -> void:
	if owner.values.has(key) and not assigned_to.empty():
		InputManager.removeJoyButtonEvent(owner.action, assigned_to)
	text = "_"
	assigned_to = ""
	joy_string = ""
	owner.values[key] = ""


func _on_Pressed() -> void:
	if EngineSettings.keylist.gamepad.has(assigned_to):
		Events.emit_signal(
			"gamepad_listening_started", owner, self, EngineSettings.keylist.gamepad[assigned_to]
		)
	else:
		Events.emit_signal("gamepad_listening_started", owner, self, -1)
	release_focus()
