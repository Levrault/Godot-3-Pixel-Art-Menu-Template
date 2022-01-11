extends Node

onready var audio_player := get_parent()

func _ready():
	yield(audio_player.owner, "ready")

	if not audio_player.owner.has_signal("field_popup_opened"):
		print_debug("%s doesn't have a field_popup_opened signal for %s" % [audio_player.owner.get_name(), audio_player.get_name()])
		queue_free()
		return

	if audio_player.stream == null:
		printerr("%s stream value is null" % audio_player.get_name())

	audio_player.owner.connect("field_popup_opened", self, "_on_Field_popup_opened")


func _on_Field_popup_opened() -> void:
	audio_player.stop()
	audio_player.play()
