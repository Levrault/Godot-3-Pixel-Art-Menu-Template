extends Updater


func apply(properties: Dictionary, show_dialog := true) -> void:
	OS.vsync_enabled = properties["display/window/size/use_vsync"]
