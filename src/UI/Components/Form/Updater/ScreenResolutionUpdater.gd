extends Updater


func _ready() -> void:
	if not get_parent() is Field:
		printerr("Parent %s of %s is not a field" % [get_parent().get_name(), get_name()])
	assert(get_parent() is Field)


func apply(properties: Dictionary, show_dialog := true) -> void:
	# display
	OS.window_size = Vector2(
		properties["display/window/size/test_width"], properties["display/window/size/test_height"]
	)
	OS.center_window()

	if owner.is_current_route and show_dialog:
		$ConfirmFieldValueDialog.show()
