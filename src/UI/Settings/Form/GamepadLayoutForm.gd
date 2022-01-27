# Gamepad specific page
# Add the custom value when a gamepad scheme is edited
# @category: Form
extends Form


func _ready() -> void:
	Events.connect("user_has_changed_gamepad_bindind", self, "_on_User_has_changed_gamepad_bindind")


func _on_User_has_changed_gamepad_bindind() -> void:
	Config.values[engine_file_section]["gamepad_layout"] = "custom"
	data.gamepad_layout.revert()
