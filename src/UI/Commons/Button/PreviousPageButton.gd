extends Button

signal blocked
signal clicked


func _ready():
	InputManager.connect("device_changed", self, "_on_Device_changed")
	connect("pressed", self, "_on_Pressed")
	connect("mouse_entered", self, "grab_focus")
	Events.connect("navigation_enabled", self, "set", ["disabled", false])
	Events.connect("navigation_disabled", self, "set", ["disabled", true])
	Events.connect("menu_route_changed", self, "_on_Menu_route_changed")
	visible = not Menu.history.size() == 0
	_on_Device_changed(InputManager.device, 0)


func _on_Pressed() -> void:
	if owner.has_node("Form"):
		if owner.form.is_invalid():
			owner.form.invalid_callback()
			emit_signal("blocked")
			return
		if owner.form.has_changed:
			Events.emit_signal("save_notification_enabled")
			owner.form.has_changed = false
	if Menu.history.size() > 0:
		Menu.navigate_to(Menu.history.pop_back())
		emit_signal("clicked")


func _on_Menu_route_changed(route: String) -> void:
	visible = not Menu.history.size() == 0


func _on_Device_changed(device: String, device_index: int) -> void:
	icon = InputManager.get_device_button_texture_from_action("ui_cancel", InputManager.device)
