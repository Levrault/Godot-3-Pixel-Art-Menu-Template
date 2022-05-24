extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	for key in properties:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(key), linear2db(properties[key]))
