extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	# display
	OS.window_size = Vector2(
		properties["display/window/size/test_width"], properties["display/window/size/test_height"]
	)
	OS.center_window()

	if owner.is_current_route and trigger_callback_action:
		$ConfirmFieldValueDialog.show()
