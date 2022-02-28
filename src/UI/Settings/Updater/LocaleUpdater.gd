extends Updater


func _ready() -> void:
	yield(owner, "ready")

	if Config.is_new:
		var os_locale = OS.get_locale().left(2)
		if TranslationServer.get_loaded_locales().find(os_locale):
			Events.connect("config_file_saved", self, "_on_Config_file_saved")
			Config.save_field(owner.form.engine_file_section, get_parent().key, os_locale)


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	TranslationServer.set_locale(properties.locale)
	Events.emit_signal("locale_changed")
	if trigger_callback_action:
		get_parent().save()


func _on_Config_file_saved() -> void:
	get_parent().revert()
	Events.disconnect("config_file_saved", self, "_on_Config_file_saved")
