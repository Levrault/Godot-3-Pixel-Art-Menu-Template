extends Button

export var key := ""

var assigned_to := ""
var joy_string := ""
var type := "xbox"


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func assign_with_constant(value: String) -> void:
	if value.empty():
		clear()
		return

	assigned_to = value
	text = assigned_to

	if InputManager.is_motion_event(value):
		joy_string = Input.get_joy_axis_string(EngineSettings.keylist.gamepad[value])
		var input_event_motion = InputEventJoypadMotion.new()
		input_event_motion.axis = EngineSettings.keylist.gamepad[value]
		InputMap.action_add_event(owner.action, input_event_motion)
	else:
		joy_string = Input.get_joy_button_string(EngineSettings.keylist.gamepad[value])
		var input_event_button = InputEventJoypadButton.new()
		input_event_button.button_index = EngineSettings.keylist.gamepad[value]
		InputMap.action_add_event(owner.action, input_event_button)

	owner.values[key] = assigned_to


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
