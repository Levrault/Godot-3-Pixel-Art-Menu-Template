extends VBoxContainer

var last_focused_field: KeyMapField = null


func _ready() -> void:
	Events.connect("field_focus_entered", self, "_on_Field_focus_entered")


func _on_Field_focus_entered(field) -> void:
	if not owner.is_current_route:
		return
	if last_focused_field == null:
		last_focused_field = field

	field.change_button_focus_by_name(last_focused_field.last_focused_button.get_name())
	last_focused_field = field
