extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	var joy_actions := []
	for action in properties.actions:
		InputManager.addJoyStickMotionEvent(action, properties.actions[action].axis, properties.actions[action].axis_value)
		joy_actions.append(properties.actions[action].axis)

	# remove event
	for action in properties.unmap:
		InputManager.removeJoyStickMotionEvent(action, properties.unmap[action].axis, properties.unmap[action].axis_value)
	Events.emit_signal("gamepad_stick_layout_changed", joy_actions, properties.translation_key)
