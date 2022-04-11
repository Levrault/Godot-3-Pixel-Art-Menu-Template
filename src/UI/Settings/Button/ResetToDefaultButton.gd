# Reset to default button
# Will compare the current form value to the EngineSettings data
# If different, it will enable the button
# Trigger a dialog when enabled and clicked
# @category: Button
extends Button

onready var confirmation_dialog := $ResetToDefaultDialog


func _ready():
	yield(owner, "ready")
	InputManager.connect("device_changed", self, "_on_Device_changed")
	Events.connect("locale_changed", self, "translate")
	Events.connect("config_file_saved", self, "_on_Config_file_saved")
	Events.connect("navigation_disabled", self, "set", ["disabled", true])
	connect("pressed", self, "_on_Pressed")
	connect("mouse_entered", self, "_on_Mouse_entered")

	confirmation_dialog.cancel_button.connect("pressed", self, "_on_Config_file_saved")
	confirmation_dialog.confirm_button.connect("pressed", self, "_on_Confirmation_ok_pressed")
	confirmation_dialog.dialog_text.text = tr("commons.restore_default_settings_message").format(
		{section = tr(owner.form.section_title)}
	)

	disabled = _is_equal_to_default_config()
	_on_Device_changed(InputManager.device, 0)


func translate() -> void:
	confirmation_dialog.dialog_text.text = tr("commons.restore_default_settings_message").format(
		{section = tr(owner.form.section_title)}
	)


func popup_hidden():
	owner.focus_default_field()


func _is_equal_to_default_config() -> bool:
	var config_values = Config.values[owner.form.engine_file_section].duplicate()
	var engine_values = EngineSettings.default[owner.form.engine_file_section].duplicate()

	# compare by hash
	if config_values.hash() == engine_values.hash():
		return true

	# compare each value, depending on their type
	var is_disabled := true
	for key in config_values:
		if not is_disabled:
			return is_disabled
		if typeof(config_values[key]) == TYPE_DICTIONARY:
			var config_sorted_values: Array = config_values[key].values()
			var engine_sorted_values: Array = engine_values[key].values()
			config_sorted_values.sort()
			engine_sorted_values.sort()
			if config_sorted_values != engine_sorted_values:
				is_disabled = false
			continue
		if typeof(config_values[key]) == TYPE_REAL:
			if config_values[key] != float(engine_values[key]):
				is_disabled = false
			continue
		if config_values[key] != engine_values[key]:
			is_disabled = false

	return is_disabled


func _on_Pressed() -> void:
	confirmation_dialog.show()


func _on_Confirmation_ok_pressed() -> void:
	owner.form.reset()


func _on_Config_file_saved() -> void:
	if not owner.is_current_route:
		return
	disabled = _is_equal_to_default_config()


func _on_Device_changed(device: String, device_index: int) -> void:
	var joy_string := InputManager.get_device_button_from_action("ui_reset_to_default", device)
	icon = InputManager.get_device_icon_texture_from_action(joy_string, device)


func _on_Mouse_entered() -> void:
	if disabled:
		return
	grab_focus()
