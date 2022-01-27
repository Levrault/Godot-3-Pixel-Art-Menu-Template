# Rebind gamepad form
# Manage how a gamepad can be edited
# @category: Form
extends RebindForm

var device := "xbox"


func reset() -> void:
	Config.save_section(engine_file_section, EngineSettings.get_gamepad_layout())
	.reset()


# save data and sync the current scheme to other controller
# e.g. you edit an Xbox gamepad scheme, the same scheme will
# be apply to nintendo and sony gamepad
func save() -> void:
	var layout_is_valid := true
	var data_to_save := {}
	for gamepad_device in InputManager.all_gamepad_devices:
		data_to_save[gamepad_device] = {}
		for key in data:
			data_to_save[gamepad_device][key] = {}

			# an empty field in gamepad is consider as invalid
			if data[key].values.default.empty():
				layout_is_valid = false
				data_to_save[gamepad_device][key]["default"] = {}
			else:
				data_to_save[gamepad_device][key]["default"] = EngineSettings.get_gamepad_button_from_joy_string(
					data[key].values.default.joy_value,
					data[key].values.default.joy_string,
					gamepad_device
				)

	if layout_is_valid:
		Config.save_section(engine_file_section, data_to_save)
		Events.emit_signal("gamepad_layout_changed")
		Events.emit_signal("user_has_changed_gamepad_bindind")
	has_changed = true


func get_invalid_fields() -> Array:
	var invalid_fields := []
	for key in data:
		var field = data[key]
		if field.required and field.default_button.assigned_to.empty():
			invalid_fields.append(field)

	return invalid_fields


# Find and return a specific field
# Use for conflicted field
func get_mapped_gamepad_or_null(joy_string: String) -> GamepadMapField:
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
