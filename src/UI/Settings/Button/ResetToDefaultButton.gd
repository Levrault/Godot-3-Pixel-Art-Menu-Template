extends Button

onready var confirmation_dialog := $ConfirmationDialog


func _ready():
	yield(owner, "ready")
	Events.connect("config_file_saved", self, "_on_Config_file_saved")
	connect("pressed", self, "_on_Pressed")
	confirmation_dialog.get_close_button().hide()
	confirmation_dialog.connect("popup_hide", Events, "emit_signal", ["overlay_hidden"])
	confirmation_dialog.get_ok().connect("pressed", self, "_on_Confirmation_ok_pressed")
	disabled = _is_equal_to_default_config()


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
			if config_values[key].values() != engine_values[key].values():
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

