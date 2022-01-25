# Decoupled system to connect an Audioplayer
# To his owner with the custom signal field_item_selected
# @category: Audio
extends Node

enum TRIGGER_ON { all, negative, positive }
export (TRIGGER_ON) var trigger_on = TRIGGER_ON.all

onready var audio_player := get_parent()


func _ready():
	yield(audio_player.owner, "ready")

	if not audio_player.owner.has_signal("field_item_selected"):
		queue_free()
		return

	if audio_player.stream == null:
		printerr("%s stream value is null" % audio_player.get_name())

	audio_player.owner.connect("field_item_selected", self, "_on_Field_item_selected")


func _on_Field_item_selected(item) -> void:
	if trigger_on == TRIGGER_ON.positive:
		if item:
			audio_player.stop()
			audio_player.play()
		return

	if trigger_on == TRIGGER_ON.negative:
		if not item:
			audio_player.stop()
			audio_player.play()
		return

	audio_player.stop()
	audio_player.play()
