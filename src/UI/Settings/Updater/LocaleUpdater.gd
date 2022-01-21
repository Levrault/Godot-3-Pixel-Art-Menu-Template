extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	print(Config.is_new)
	TranslationServer.set_locale(properties.locale)

	if trigger_callback_action:
		get_parent().save()
