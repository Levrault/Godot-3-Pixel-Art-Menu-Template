# Decoupled system to connect an Audioplayer
# To his owner with the signal pressed
# @category: Audio
extends Node


func _ready():
	var audio_player := get_parent()

	if not audio_player.owner.has_signal("pressed"):
		print_debug(
			(
				"%s doesn't have a pressed signal for %s"
				% [audio_player.owner.get_name(), audio_player.get_name()]
			)
		)
		queue_free()
		return

	if audio_player.stream == null:
		printerr("%s stream value is null" % audio_player.get_name())

	audio_player.owner.connect("pressed", audio_player, "play")
