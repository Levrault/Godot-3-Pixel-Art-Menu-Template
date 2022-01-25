# Decoupled system to connect an Audioplayer
# To his owner with the signal popup_hide
# @category: Audio
extends Node


func _ready():
	var audio_player = get_parent()
	yield(audio_player.owner, "ready")

	if not audio_player.owner.has_signal("popup_hide"):
		print_debug(
			(
				"%s doesn't have a popup_hide signal for %s"
				% [audio_player.owner.get_name(), audio_player.get_name()]
			)
		)
		queue_free()
		return

	if audio_player.stream == null:
		printerr("%s stream value is null" % get_name())

	audio_player.owner.connect("popup_hide", audio_player, "play")
