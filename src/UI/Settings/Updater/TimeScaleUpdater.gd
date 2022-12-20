extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	Events.emit_signal("engine_time_scale_changed", properties.time_scale)
