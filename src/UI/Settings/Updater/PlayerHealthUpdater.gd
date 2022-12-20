extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	Events.emit_signal("player_max_health_changed", properties.health)
