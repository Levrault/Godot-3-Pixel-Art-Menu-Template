extends Node

onready var audio_player := get_parent()


func _ready():
	yield(audio_player.owner, "ready")
	yield(get_tree(), "idle_frame")

	if audio_player.owner is FieldSet:
		queue_free()
		return

	if owner.stream == null:
		printerr("%s stream value is null" % owner.get_name())

	Events.connect("menu_transition_finished", self, "_on_Menu_transition_finished")
	Events.connect("menu_transition_started", self, "_on_Menu_transition_started")
	audio_player.owner.connect("focus_entered", audio_player, "play")
	audio_player.owner.connect("mouse_entered", self, "_on_Mouse_enter")


func _on_Menu_transition_finished() -> void:
	audio_player.owner.connect("focus_entered", audio_player, "play")


func _on_Menu_transition_started(anim_name: String) -> void:
	audio_player.owner.disconnect("focus_entered", audio_player, "play")


func _on_Mouse_enter() -> void:
	if audio_player.owner.has_focus() or audio_player.owner.disabled:
		return
	audio_player.play()
