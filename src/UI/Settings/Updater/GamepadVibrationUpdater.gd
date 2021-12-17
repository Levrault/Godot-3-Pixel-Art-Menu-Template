extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	if trigger_callback_action:
		Input.start_joy_vibration(0, properties.force, properties.force, .350)
