extends Updater


func apply(properties: Dictionary, show_dialog := true) -> void:
	OS.window_fullscreen = properties["display/window/size/fullscreen"]
	OS.window_borderless = properties["display/window/size/borderless"]

	if owner.is_current_route and show_dialog:
		$ConfirmFieldValueDialog.show()
