extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	for key in properties:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(key), properties[key])

	if owner.is_current_route and trigger_callback_action:
		$AudioStreamPlayer.play()
