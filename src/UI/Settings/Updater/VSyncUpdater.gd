extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	OS.vsync_enabled = properties["display/window/size/use_vsync"]
