extends AtlasIcon


func _ready() -> void:
	timer.stop()


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed(action):
		texture = alt_icon_texture
		return

	if event.is_action_released(action):
		texture = icon_texture
		return


func _on_Device_changed(device: String, device_index: int) -> void:
	var joy_string := InputManager.get_device_button_from_action(action, device)
	icon_texture = InputManager.get_device_icon_texture_from_action(joy_string, device)
	alt_icon_texture = InputManager.get_device_icon_texture_from_action(joy_string, device, true)

	if icon_texture == null:
		icon_texture = InputManager.get_device_icon_texture_fallback(device)
		label.text = joy_string
		label.show()

	texture = icon_texture
	next_icon = Icon.ALT
