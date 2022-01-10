extends Form


func _ready() -> void:
	Events.connect("user_has_changed_gamepad_bindind", self, "_on_User_has_changed_gamepad_bindind")


func _on_User_has_changed_gamepad_bindind() -> void:
	# key from engine.cfg
	Config.values[engine_file_section]["gamepad_layout"] = "custom"
	data.gamepad_layout.revert()
