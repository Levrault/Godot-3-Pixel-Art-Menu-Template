extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	var joy_actions := []
	for action in properties.actions:
		InputManager.addJoyMotionEvent(action, properties.actions[action])
		joy_actions.append(properties.actions[action])

	# remove event
	for action in properties.unmap:
		InputManager.removeJoyMotionEvent(action, properties.unmap[action])
	Events.emit_signal("gamepad_stick_layout_changed", joy_actions, properties.translation_key)
