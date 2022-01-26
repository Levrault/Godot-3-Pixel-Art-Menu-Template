# Save icon notification
# @category: Notification
extends Control


func _ready():
	Events.connect("save_notification_enabled", self, "_on_Save_notification_enabled")


func _on_Save_notification_enabled() -> void:
	Events.connect("menu_transition_finished", self, "_on_Menu_transition_finished")


func _on_Menu_transition_finished() -> void:
	$AnimationPlayer.play("saving")
	Events.disconnect("menu_transition_finished", self, "_on_Menu_transition_finished")
