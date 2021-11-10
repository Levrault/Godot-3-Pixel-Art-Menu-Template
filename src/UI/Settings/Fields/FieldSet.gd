class_name FieldSet, "res://assets/icons/fieldset.svg"
extends Control

var field: Field = null

onready var focus_rect = $FocusRect
onready var tween = $Tween
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

	field.connect("field_focus_entered", self, "_on_Field_focus_entered")
	field.connect("field_focus_exited", self, "_on_Field_focus_exited")
	focus_rect.modulate.a = 0.0


func _on_Field_focus_entered() -> void:
	tween.interpolate_property(
		focus_rect, "modulate:a", 0.0, 1.0, .250, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()


func _on_Field_focus_exited() -> void:
	tween.interpolate_property(
		focus_rect, "modulate:a", 1.0, 0.0, .250, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()
