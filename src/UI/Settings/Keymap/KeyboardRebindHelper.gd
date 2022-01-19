# fix how hover should work with keymapfield since they have two input
extends Node

var last_focused_field: KeyMapField = null


func _on_Field_focus_entered(field) -> void:
	if not owner.is_current_route:
		return
	if last_focused_field == null:
		last_focused_field = field

	last_focused_field.emit_signal("field_focus_exited")
	field.change_button_focus_by_name(last_focused_field.last_focused_button.get_name())
	field.is_inner_navigation_activated = true

	if last_focused_field != field:
		last_focused_field.is_inner_navigation_activated = false
		last_focused_field.last_focused_button = null
		last_focused_field = field


# fix when mouse exit but keyboard regain focus
func _on_Button_focus_entered(field) -> void:
	if field != last_focused_field:
		return
	if not InputManager.device == InputManager.DEVICE_KEYBOARD:
		return
	Events.emit_signal("fieldset_inner_field_navigated", field)
