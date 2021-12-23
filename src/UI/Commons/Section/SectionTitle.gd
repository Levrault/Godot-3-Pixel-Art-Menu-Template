tool
extends VBoxContainer

export var text := "" setget _set_text


func _set_text(value: String) -> void:
	$Label.text = value
