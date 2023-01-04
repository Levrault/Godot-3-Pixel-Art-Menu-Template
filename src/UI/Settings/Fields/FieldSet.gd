# Manage all the visuel when a field is focused by the user
# @category: Field
tool
class_name FieldSet, "res://editor/icons/fieldset.svg"
extends Control

signal fieldset_focus_entered
signal fieldset_focus_exited

export var is_hidden_on_focus := false setget _set_is_hidden_on_focus

var field = null
var label: Label = null
var is_hovered := false

onready var anim = $AnimationPlayer
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

	Events.connect("fieldset_inner_field_navigated", self, "_on_Fieldset_inner_field_navigated")
	connect("mouse_exited", self, "_on_Mouse_exited")
	connect("mouse_entered", self, "_on_Mouse_focus_entered")
	field.connect("field_focus_entered", self, "_on_Field_focus_entered")
	field.connect("field_focus_exited", self, "_on_Field_focus_exited")

	if is_hidden_on_focus:
		anim.play("fieldset_panel_hidden")


func clear() -> void:
	is_hovered = false
	Events.disconnect("fieldset_cleared", self, "_on_Field_cleared")
	_on_Field_focus_exited()


func _set_is_hidden_on_focus(value: bool) -> void:
	is_hidden_on_focus = value
	if value:
		$AnimationPlayer.play("fieldset_panel_hidden")
	else:
		$AnimationPlayer.play("RESET")


func _on_Field_focus_entered() -> void:
	Events.emit_signal("fieldset_cleared", self)
	Events.emit_signal("field_description_changed", field.description)
	emit_signal("fieldset_focus_entered")

	if not is_hidden_on_focus:
		anim.play("fieldset_focus_entered")


func _on_Field_focus_exited() -> void:
	Events.emit_signal("field_description_changed", "")
	emit_signal("fieldset_focus_exited")

	if not is_hidden_on_focus:
		anim.play("fieldset_focus_exited")


func _on_Mouse_focus_entered() -> void:
	if is_hovered:
		return
	is_hovered = true

	field.call_deferred("grab_focus")

	Events.connect("fieldset_cleared", self, "_on_Field_cleared")
	Events.emit_signal("fieldset_cleared", self)

	call_deferred("_on_Field_focus_entered")


# clear the fieldset when the mouse leave the fieldset area
# @see https://github.com/godotengine/godot/issues/16854#issuecomment-1010931622
func _on_Mouse_exited() -> void:
	if not Rect2(Vector2(), rect_size).has_point(get_local_mouse_position()):
		clear()


# prevent the fieldset to be cleared when the user navigate
# between multiple field input
func _on_Field_cleared(fieldset: FieldSet) -> void:
	if not owner.is_current_route:
		return
	if fieldset == self:
		return
	if not fieldset.is_hovered:
		return
	clear()


# prevent the fieldset to be cleared when the user navigate
# between multiple field input
func _on_Fieldset_inner_field_navigated(focused_field) -> void:
	if not owner.is_current_route:
		return
	if is_hovered:
		return
	if focused_field != field:
		return
	if not is_hidden_on_focus:
		anim.play("fieldset_focus_entered")
	Events.emit_signal("field_description_changed", field.description)
