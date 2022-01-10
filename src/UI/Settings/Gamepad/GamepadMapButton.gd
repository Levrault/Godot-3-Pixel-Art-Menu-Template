extends Button

export var key := ""

var assigned_to := ""
var joy_string := ""
var type := "xbox"


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")
	type = InputManager.DEVICE_XBOX_CONTROLLER


func assign_with_constant(value: String) -> void:
	if value.empty():
		clear()
		return

	assigned_to = value
	text = assigned_to

	if InputManager.is_motion_event(value):
		joy_string = Input.get_joy_axis_string(EngineSettings.keylist.gamepad[value])
		InputManager.addJoyMotionEvent(owner.action, value)
	else:
		joy_string = Input.get_joy_button_string(EngineSettings.keylist.gamepad[value])
		InputManager.addJoyButtonEvent(owner.action, value)

	owner.values[key] = { 
		joy_value = EngineSettings.keylist.gamepad[assigned_to],
		device_joy_string = assigned_to,
		joy_string = joy_string
	}


func clear() -> void:
	if owner.values.has(key) and not assigned_to.empty():
		var input_event = InputEventJoypadButton.new()
		input_event.set_button_index(EngineSettings.keylist.gamepad[assigned_to])
		InputMap.action_erase_event(owner.action, input_event)
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
