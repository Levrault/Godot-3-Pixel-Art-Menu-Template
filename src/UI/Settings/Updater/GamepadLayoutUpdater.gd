extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	for device in InputManager.all_gamepad_devices:
		Config.values.gamepad_bindind[device] = EngineSettings.gamepad[device][properties.layout]
	Events.emit_signal("gamepad_layout_changed")
