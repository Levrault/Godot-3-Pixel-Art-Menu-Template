extends Updater

const CUSTOM_LAYOUT = "custom"
var previous_actions := []


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	
	# clear previous config
	for device in InputManager.all_gamepad_devices:
		for action in previous_actions:
			InputManager.removeJoyButtonEvent(action.key, action.value)
			InputManager.removeJoyMotionEvent(action.key, action.value)
	
	# udpate
	if properties.layout != CUSTOM_LAYOUT:
		for device in InputManager.all_gamepad_devices:
			for action in EngineSettings.gamepad[device][properties.layout]:
				if not InputMap.has_action(action):
					InputMap.add_action(action)

				var value = EngineSettings.gamepad[device][properties.layout][action].default
				if InputManager.is_motion_event(value):
					InputManager.addJoyMotionEvent(action, value)
				else:
					InputManager.addJoyButtonEvent(action, value)
					
				# cache previous action
				previous_actions.append({key = action, value = value})
	else:
		for device in InputManager.all_gamepad_devices:
			for action in Config.values.gamepad_bindind[device]:
				if not InputMap.has_action(action):
					InputMap.add_action(action)

				var value = Config.values.gamepad_bindind[device][action].default
				if InputManager.is_motion_event(value):
					InputManager.addJoyMotionEvent(action, value)
				else:
					InputManager.addJoyButtonEvent(action, value)
					
				# cache previous action
				previous_actions.append({key = action, value = value})

	Events.emit_signal("gamepad_layout_changed")
