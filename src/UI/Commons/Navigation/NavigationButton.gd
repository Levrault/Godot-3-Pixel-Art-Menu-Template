# Enable to navigate between all the differents menu ui
# by setting up which menu needs to be show (based on node name)
# @category: Navigation
class_name NavigationButton, "res://assets/icons/navigation.svg"
extends Button

export var navigate_to := ""
export var is_default_focused := false


# Focus itself if default focused and menu is visible
func _ready() -> void:
	yield(owner, "ready")
	connect("pressed", self, "_on_Pressed")
	connect("mouse_entered", self, "grab_focus")

	if is_default_focused:
		owner.last_clicked_button = self
		if owner.visible:
			grab_focus()


# Update Menu navigation history (Autoload/Menu.gd)
# Set itself at last clicked button
func _on_Pressed() -> void:
	owner.last_clicked_button = self
	Menu.history.append(owner.get_name())
	Menu.navigate_to(navigate_to)
	Menu.current_route = navigate_to
	print_debug("%s has change navigation history : %s" % [owner.get_name(), Menu.history])
