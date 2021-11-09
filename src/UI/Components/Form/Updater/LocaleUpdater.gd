extends Updater


func apply(properties: Dictionary, trigger_callback_action := true) -> void:
	TranslationServer.set_locale(properties.locale)
	get_parent().save()
