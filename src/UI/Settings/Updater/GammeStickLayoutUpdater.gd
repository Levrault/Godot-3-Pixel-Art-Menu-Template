extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	var joy_actions := []
	for action in properties:
		InputManager.addJoyMotionEvent(action, properties[action])
		joy_actions.append(properties[action])
	Events.emit_signal("gamepad_stick_layout_changed", joy_actions)
