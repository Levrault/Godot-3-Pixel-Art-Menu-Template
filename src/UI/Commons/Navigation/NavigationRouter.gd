# Clear history on load
# @category: Navigation
class_name NavigationRouter
extends Control


func _ready() -> void:
	Menu.history.clear()
