extends Updater

export var confirmation_dialog_path := NodePath()

onready var confirmation_dialog := get_node(confirmation_dialog_path)


func ready() -> void:
	if confirmation_dialog_path == null:
		printerr("%s - confirmation_dialog_path is null" % get_parent().get_name())


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	OS.window_fullscreen = properties["display/window/size/fullscreen"]
	OS.window_borderless = properties["display/window/size/borderless"]

	if owner.is_current_route and trigger_callback_action:
		confirmation_dialog.show()
