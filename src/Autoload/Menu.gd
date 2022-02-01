# Manage menu navigation and historic
# @category: Navigation
extends Node

var history := []
var current_route := ""


# Navigate to a new menu
func navigate_to(to: String, transition: String = "fade") -> void:
	Events.emit_signal("menu_route_changed", to)
	Events.emit_signal("menu_transition_started", transition)
