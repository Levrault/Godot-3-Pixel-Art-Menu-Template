extends Form


func reset() -> void:
	var data_to_save := {}
	data_to_save[engine_file_section] = EngineSettings.get_keyboard_or_mouse_key_from_keyboard_variant()
	Config.save_file(data_to_save)
	.reset()


func get_mapped_key_or_null(scancode: int) -> KeyMapField:
	for key in data:
		var field = data[key]
		for action_key in field.values:
			if field.values[action_key] == scancode:
				return field
	return null


func unmap_key(scancode: int) -> Dictionary:
	for key in data:
		var field = data[key]
		for action_key in field.values:
			if field.values[action_key] == scancode:
				return {matched = true, field = field}
	return {matched = false, field = null}
