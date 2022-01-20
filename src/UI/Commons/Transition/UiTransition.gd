# Manage menu transition
# transition_fade_mid_transition and transition_fade_finished are emitted from AnimationPlayer
extends Control

onready var anim := $AnimationPlayer


func _ready() -> void:
	Events.connect("menu_transition_started", self, "_on_Transition_started")


func emit_animation_finished() -> void:
	print("emit_animation_finished")
	Events.emit_signal("menu_transition_finished")


func _on_Transition_started(anim_name: String) -> void:
	anim.play(anim_name)


func _on_Mid_animation() -> void:
	Events.emit_signal("menu_transition_mid_animated")
	print("_on_Mid_animation")
