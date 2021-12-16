extends BindingForm

var device := "xbox"


func reset() -> void:
	var data_to_save := {}
	data_to_save[engine_file_section] = EngineSettings.get_gamepad_layout()
	Config.save_file(data_to_save)
	.reset()


func save() -> void:
	var data_to_save := {}
	data_to_save[engine_file_section] = {}
	data_to_save[engine_file_section][device] = {}
	for key in data:
		data_to_save[engine_file_section][device][key] = data[key].values
	Config.save_file(data_to_save)


func get_invalid_fields() -> Array:
	var invalid_fields := []
	for key in data:
		var field = data[key]
		if field.required and field.default_button.assigned_to.empty():
			invalid_fields.append(field)

	return invalid_fields


func get_mapped_gamepad_or_null(joy_string: String) -> KeyMapField:
	for key in data:
		var field = data[key]
		if data[key].default_button.joy_string == joy_string:
			return field
	return null


func unmap_key(button_index: int) -> Dictionary:
	for key in data:
		var field = data[key]
		for action_key in field.values:
			if field.values[action_key] == button_index:
				return {matched = true, field = field}
	return {matched = false, field = null}
