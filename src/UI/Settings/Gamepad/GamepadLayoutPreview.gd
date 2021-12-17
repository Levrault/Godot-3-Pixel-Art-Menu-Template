extends Control


func _ready():
	Events.connect("gamepad_layout_changed", self, "_on_Gamepad_layout")


func _on_Gamepad_layout() -> void:
	print(Config.values[owner.form.engine_file_section][InputManager.DEVICE_XBOX_CONTROLLER])


func _on_Option_changed(value) -> void:
	print(value)
