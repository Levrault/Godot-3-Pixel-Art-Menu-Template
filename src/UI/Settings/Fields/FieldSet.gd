class_name FieldSet, "res://assets/icons/fieldset.svg"
extends Control

var field = null

onready var focus_rect = $FocusRect
onready var container = $MarginContainer/FieldContainer


func _ready():
	if container.get_child_count() == 0:
		printerr("Field %s doesn't have any child" % get_name())
		return

	for child in container.get_children():
		if not child.is_in_group("GameSettings"):
			continue
		field = child

	if field == null:
		printerr("Field %s doesn't have any field" % get_name())
		return

	field.connect("mouse_entered", self, "_on_Mouse_entered")
	Events.connect("field_focus_entered", self, "_on_Field_focus_entered")
	focus_rect.modulate.a = 0.0


func _on_Field_focus_entered(focused_field) -> void:
	if focused_field != field:
		focus_rect.modulate.a = 0.0
		return
	focus_rect.modulate.a = 1.0


func _on_Mouse_entered() -> void:
	Events.emit_signal("field_focus_entered", field)
	focus_rect.modulate.a = 1.0
