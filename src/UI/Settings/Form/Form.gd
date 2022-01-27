# Manage page's data changes state
# @category: Form
class_name Form, "res://assets/icons/form.svg"
extends Node

export var engine_file_section := ""
export var section_title := ""

var data := {}
var has_changed := false


# call field's reset function
# use to reset them to their default state
func reset() -> void:
	has_changed = true
	for key in data:
		data[key].reset()

		if data[key].has_method("save"):
			data[key].save()


# virtual function for more specific form that
# can be invalid
func is_invalid() -> bool:
	return false
