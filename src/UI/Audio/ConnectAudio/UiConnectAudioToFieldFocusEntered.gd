extends Node

onready var audio_player := get_parent()


func _ready():
	yield(audio_player.owner, "ready")
	yield(get_tree(), "idle_frame")

	if not audio_player.owner is FieldSet:
		queue_free()
		return

	if not audio_player.owner.has_signal("fiedset_focus_entered"):
		print_debug(
			(
				"%s doesn't have a fiedset_focus_entered signal for %s"
				% [audio_player.owner.get_name(), audio_player.get_name()]
			)
		)
		queue_free()
		return

	if owner.stream == null:
		printerr("%s stream value is null" % owner.get_name())

	Events.connect("menu_transition_finished", self, "_on_Menu_transition_finished")
	Events.connect("menu_transition_started", self, "_on_Menu_transition_started")
	audio_player.owner.connect("fiedset_focus_entered", audio_player, "play")


func _on_Menu_transition_finished() -> void:
	audio_player.owner.connect("fiedset_focus_entered", audio_player, "play")


func _on_Menu_transition_started(anim_name: String) -> void:
	audio_player.owner.disconnect("fiedset_focus_entered", audio_player, "play")


func _on_Mouse_enter() -> void:
	if audio_player.owner.has_focus() or audio_player.owner.disabled:
		return
	audio_player.play()
