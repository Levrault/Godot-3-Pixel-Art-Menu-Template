# Keyboard button
# Trigger bindind action when pressed
# @category: Keyboard, Rebind
extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	OS.shell_open(owner.url)
