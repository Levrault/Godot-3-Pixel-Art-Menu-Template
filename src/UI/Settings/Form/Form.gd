class_name Form, "res://assets/icons/form.svg"
extends Node

signal pristine_value_changed(value)

export var engine_file_section := ""
export var section_title := ""

var data := {}


func reset() -> void:
	for key in data:
		data[key].reset()


func revert() -> void:
	for key in data:
		if data[key].is_pristine:
			continue
		data[key].revert()


func is_invalid() -> bool:
	return false
