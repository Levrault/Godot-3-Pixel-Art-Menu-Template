# Decoupled system to connect an Audioplayer
# To his owner with the custom signal field_item_focused
# @category: Audio
extends Node

onready var audio_player := get_parent()


func _ready():
	yield(audio_player.owner, "ready")

	if not audio_player.owner.has_signal("field_item_focused"):
		print_debug(
			(
				"%s doesn't have a field_item_focused signal for %s"
				% [audio_player.owner.get_name(), audio_player.get_name()]
			)
		)
		queue_free()
		return

	if audio_player.stream == null:
		printerr("%s stream value is null" % get_name())

	audio_player.owner.connect("field_item_focused", self, "_on_Field_item_focused")


func _on_Field_item_focused(item) -> void:
	audio_player.stop()
	audio_player.play()
