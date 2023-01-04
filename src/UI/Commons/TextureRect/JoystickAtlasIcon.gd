extends AtlasIcon

var joy_stick_action := "JOY_L3"


func _ready():
	Events.connect("gamepad_stick_layout_changed", self, "_on_Gamepad_stick_layout_changed")


func _on_Device_changed(device: String, device_index: int) -> void:
	var joy_string := InputManager.get_device_button_from_action(action, device)

	if InputManager.is_using_gamepad():
		icon_texture = InputManager.get_device_icon_texture_from_action(joy_stick_action, device)
		alt_icon_texture = InputManager.get_device_icon_texture_from_action(
			joy_stick_action, device, true
		)
	else:
		icon_texture = InputManager.get_device_icon_texture_from_action(joy_string, device)
		alt_icon_texture = InputManager.get_device_icon_texture_from_action(
			joy_string, device, true
		)

	if icon_texture == null:
		icon_texture = InputManager.get_device_icon_texture_fallback(device)
		label.text = joy_string
		label.show()

	if alt_icon_texture == null:
		timer.stop()
		if timer.is_connected("timeout", self, "_on_Timeout"):
			timer.disconnect("timeout", self, "_on_Timeout")
	elif not timer.is_connected("timeout", self, "_on_Timeout"):
		timer.start()
		timer.connect("timeout", self, "_on_Timeout")

	texture = icon_texture
	next_icon = Icon.ALT


func _on_Gamepad_stick_layout_changed(joy_actions: Array, translation_key: String) -> void:
	joy_stick_action = "JOY_L3" if joy_actions[0] == "JOY_AXIS_0" else "JOY_R3"
