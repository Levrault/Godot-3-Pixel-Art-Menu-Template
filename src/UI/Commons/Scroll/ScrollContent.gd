# Manage the behavior of a ScrollContainer
# depending on which device is used
# keyboard and gamepad will required the follow_focus to be true
# while the mouse will needs it to be false
extends ScrollContainer


func _ready():
	owner.connect("navigation_finished", self, "_on_Navigation_finished")


func _on_Navigation_finished() -> void:
	if not owner.is_current_route:
		if InputManager.is_connected("device_changed", self, "_on_Device_changed"):
			InputManager.disconnect("device_changed", self, "_on_Device_changed")
		return
	if not InputManager.is_connected("device_changed", self, "_on_Device_changed"):
		InputManager.connect("device_changed", self, "_on_Device_changed")
	follow_focus = not InputManager.device == InputManager.DEVICE_MOUSE


func _on_Device_changed(device, device_index) -> void:
	if not owner.is_current_route:
		return
	follow_focus = not InputManager.device == InputManager.DEVICE_MOUSE
