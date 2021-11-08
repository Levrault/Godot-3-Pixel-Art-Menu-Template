extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	OS.window_fullscreen = properties["display/window/size/fullscreen"]
	OS.window_borderless = properties["display/window/size/borderless"]

	if owner.is_current_route and trigger_callback_action:
		$ConfirmFieldValueDialog.show()
