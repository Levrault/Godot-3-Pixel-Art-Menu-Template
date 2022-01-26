# @category: Label
tool
extends VBoxContainer

export var text := "" setget _set_text


func _ready() -> void:
	$Label.text = text


func _set_text(value: String) -> void:
	text = value
	$Label.text = value
