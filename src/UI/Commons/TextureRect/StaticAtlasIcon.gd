extends TextureRect

export var action := ""

onready var label := $Label


func _ready():
	InputManager.connect("device_changed", self, "_on_Device_changed")
	_on_Device_changed(InputManager.device, 0)


func _on_Device_changed(device: String, device_index: int) -> void:
	var joy_string := InputManager.get_device_button_from_action(action, device)
	texture = InputManager.get_device_icon_texture_from_action(joy_string, device)

	if texture == null:
		texture = InputManager.get_device_icon_texture_fallback(device)
		label.text = joy_string
		label.show()
