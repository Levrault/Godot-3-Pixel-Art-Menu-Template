# Switch when a NavigationButton is click
# @category: Navigation
class_name NavigationSwitch
extends Control

signal navigation_finished

export var default_field_to_focus: NodePath

var last_clicked_button: Button = null
var buttons := []
var is_current_route := false

# Settings page will have a form node
onready var form: Form = get_node_or_null("Form")


func _ready() -> void:
	Events.connect("menu_route_changed", self, "_on_Menu_route_changed")
	Events.connect("menu_transition_mid_animated", self, "_on_Transiton_mid_animated")


func focus_default_field() -> void:
	get_node(default_field_to_focus).grab_focus()


func _on_Menu_route_changed(id: String) -> void:
	if id != get_name():
		visible = false
		is_current_route = false
		return

	is_current_route = true
	print_debug("%s route has been set" % [id])


# Manage visibily during animation transition
func _on_Transiton_mid_animated() -> void:
	if not is_current_route:
		return

	visible = true
	if last_clicked_button:
		last_clicked_button.grab_focus()
	elif default_field_to_focus:
		focus_default_field()

	emit_signal("navigation_finished")
	print_debug("%s is now visible" % [get_name()])
