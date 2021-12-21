extends Button

onready var confirmation_dialog := $ConfirmationDialog


func _ready():
	yield(owner, "ready")
	InputManager.connect("device_changed", self, "_on_Device_changed")
	Events.connect("config_file_saved", self, "_on_Config_file_saved")
	Events.connect("navigation_enabled", self, "set", ["disabled", false])
	Events.connect("navigation_disabled", self, "set", ["disabled", true])
	connect("pressed", self, "_on_Pressed")

	confirmation_dialog.get_close_button().hide()
	confirmation_dialog.connect("popup_hide", Events, "emit_signal", ["overlay_hidden"])
	confirmation_dialog.get_ok().connect("pressed", self, "_on_Confirmation_ok_pressed")

	disabled = _is_equal_to_default_config()
	_on_Device_changed(InputManager.get_current_device(), 0)


func _is_equal_to_default_config() -> bool:
	var config_values = Config.values[owner.form.engine_file_section].duplicate()
	var engine_values = EngineSettings.default[owner.form.engine_file_section].duplicate()

	# compare by hash
	if config_values.hash() == engine_values.hash():
		return true

	# compare each value
	var is_disabled := true
	for key in config_values:
		if not is_disabled:
			continue
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
	Events.emit_signal("overlay_displayed")
	confirmation_dialog.popup()


func _on_Confirmation_ok_pressed() -> void:
	Events.emit_signal("overlay_hidden")
	owner.form.reset()


func _on_Config_file_saved() -> void:
	if not owner.is_current_route:
		return
	disabled = _is_equal_to_default_config()


func _on_Device_changed(device: String, device_index: int) -> void:
	icon = InputManager.get_device_button_texture_from_action(
		"ui_reset_to_default", InputManager.device
	)
