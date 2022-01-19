class_name Form, "res://assets/icons/form.svg"
extends Node

export var engine_file_section := ""
export var section_title := ""

var data := {}
var has_changed := false


func reset() -> void:
	has_changed = true
	for key in data:
		data[key].reset()

		if data[key].has_method("save"):
			data[key].save()


func revert() -> void:
	has_changed = true
	for key in data:
		if data[key].is_pristine:
			continue
		data[key].revert()


func is_invalid() -> bool:
	return false
