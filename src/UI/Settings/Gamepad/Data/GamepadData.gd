extends TextureRect
class_name GamepadData

var action := "" setget set_action

onready var label := $Label


func set_action(value: String) -> void:
	action = value
	label.text = value
	if action.empty():
		hide()
	else:
		show()
