class_name FieldSet, "res://assets/icons/fieldset.svg"
extends Control

var field = null
var label: Label = null

onready var focus_rect = $FocusRect
onready var container = $MarginContainer/FieldContainer


func _ready():
	if container.get_child_count() == 0:
		printerr("Field %s doesn't have any child" % get_name())
		return

	for child in container.get_children():
		if not child.is_in_group("GameSettings"):
			if child is Label:
				label = child
			continue
		field = child

	if field == null:
		printerr("Field %s doesn't have any field" % get_name())
		return

	field.connect("mouse_entered", self, "_on_Field_mouse_entered")
	field.connect("mouse_exited", self, "_on_Field_mouse_exited")
	label.connect("mouse_entered", self, "_on_Label_mouse_entered")
	label.connect("mouse_exited", self, "_on_Label_mouse_exited")
	Events.connect("field_focus_entered", self, "_on_Field_focus_entered")
	Events.connect("field_focus_exited", self, "_on_Field_focus_exited")
	focus_rect.modulate.a = 0.0
	label.mouse_filter = MOUSE_FILTER_STOP


func _on_Field_focus_entered(focused_field) -> void:
	if focused_field != field:
		focus_rect.modulate.a = 0.0
		return
	focus_rect.modulate.a = 1.0
	Events.emit_signal("field_description_changed", focused_field.description)


func _on_Field_focus_exited(focused_field) -> void:
	if focused_field != field:
		return
	focus_rect.modulate.a = 0.0
	Events.emit_signal("field_description_changed", "")


func _on_Field_mouse_entered() -> void:
	Events.emit_signal("field_focus_entered", field)


func _on_Field_mouse_exited() -> void:
	focus_rect.modulate.a = 0.0


func _on_Label_mouse_entered() -> void:
	Events.emit_signal("field_focus_entered", field)


func _on_Label_mouse_exited() -> void:
	focus_rect.modulate.a = 0.0
