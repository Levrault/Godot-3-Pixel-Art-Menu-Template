# @category: Label
tool
extends VBoxContainer

export var text := "" setget _set_text
onready var label := $Label


func _ready() -> void:
	Events.connect("locale_changed", self, "translate")
	label.text = tr(text)


func translate() -> void:
	label.text = tr(text)


func _set_text(value: String) -> void:
	text = value
	$Label.text = value
