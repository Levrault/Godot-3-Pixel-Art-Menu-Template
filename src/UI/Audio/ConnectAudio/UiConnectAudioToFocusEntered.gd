# Decoupled system to connect an Audioplayer
# To his owner with the signal focus_entered and mouse_entered
#
# To prevent unwanted signal during navigation, a flag is set between transition
# @category: Audio
extends Node

var _should_trigger_audio := true

onready var audio_player := get_parent()


func _ready():
	yield(audio_player.owner, "ready")
	yield(get_tree(), "idle_frame")

	if audio_player.owner is FieldSet:
		queue_free()
		return

	if owner.stream == null:
		printerr("%s stream value is null" % owner.get_name())

	Events.connect("menu_transition_started", self, "_on_Menu_transition_started")
	Events.connect("menu_transition_finished", self, "_on_Menu_transition_finished")
	audio_player.owner.connect("focus_entered", self, "_on_Focus_entered")
	audio_player.owner.connect("mouse_entered", self, "_on_Mouse_enter")


func _on_Menu_transition_finished() -> void:
	_should_trigger_audio = true


func _on_Menu_transition_started(anim_name: String) -> void:
	_should_trigger_audio = false


func _on_Focus_entered() -> void:
	if not _should_trigger_audio:
		return
	audio_player.play()


func _on_Mouse_enter() -> void:
	if audio_player.owner.has_focus() or audio_player.owner.disabled or not _should_trigger_audio:
		return
	audio_player.play()
