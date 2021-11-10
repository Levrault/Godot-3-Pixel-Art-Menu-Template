# Manage go to previous history
class_name NavigationRouter
extends Control

var can_navigate := true


func _ready() -> void:
	Events.connect("navigation_enabled", self, "set", ["can_navigate", true])
	Events.connect("navigation_disabled", self, "set", ["can_navigate", false])
	Menu.history.clear()


func _input(event: InputEvent) -> void:
	if not can_navigate:
		return
	if event.is_action_pressed("ui_cancel") and Menu.history.size() > 0:
		Menu.navigate_to(Menu.history.pop_back())
