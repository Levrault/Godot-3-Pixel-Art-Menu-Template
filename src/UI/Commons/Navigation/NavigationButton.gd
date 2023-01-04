# Enable to navigate between all the differents menu ui
# by setting up which menu needs to be show (based on node name)
# @category: Navigation
class_name NavigationButton, "res://editor/icons/navigation.svg"
extends Button

export var navigate_to := ""
export var is_default_focused := false

var navigation_switch: NavigationSwitch = null


# Focus itself if default focused and menu is visible
func _ready() -> void:
	yield(owner, "ready")
	navigation_switch = find_navigation_switch(owner)
	connect("pressed", self, "_on_Pressed")
	connect("mouse_entered", self, "grab_focus")

	if is_default_focused:
		owner.last_clicked_button = self
		if owner.visible:
			grab_focus()


# loop owner to find the NavigationSwitch
# use to make navigation button compatible if
# not a direct child of a NavigationSwitch
func find_navigation_switch(node: Node) -> Node:
	if node is NavigationSwitch:
		return node

	while (not node is NavigationSwitch):
		node = node.owner

	return node


# Update Menu navigation history (Autoload/Menu.gd)
# Set itself at last clicked button
func _on_Pressed() -> void:
	navigation_switch.last_clicked_button = self
	Menu.history.append(navigation_switch.get_name())
	Menu.navigate_to(navigate_to)
	Menu.current_route = navigate_to
	print_debug("%s has change navigation history : %s" % [navigation_switch.get_name(), Menu.history])
