extends Button

var can_navigate := true


func _ready():
	connect("pressed", self, "_on_Pressed")
	Events.connect("navigation_enabled", self, "set", ["can_navigate", true])
	Events.connect("navigation_disabled", self, "set", ["can_navigate", false])
	Events.connect("menu_route_changed", self, "_on_Menu_route_changed")
	visible = not Menu.history.size() == 0


func _on_Pressed() -> void:
	if not can_navigate:
		return
	Menu.navigate_to(Menu.history.pop_back())


func _on_Menu_route_changed(route: String) -> void:
	visible = not Menu.history.size() == 0
