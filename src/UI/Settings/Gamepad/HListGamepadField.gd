extends HListField


func _ready():
	yield(owner, "ready")
	Input.connect("joy_connection_changed", self, "_on_Joy_connection_changed")


func _on_Joy_connection_changed(device_id: int, connected: bool, guid: String) -> void:
	print(device_id)
	print(connected)
	print(guid)
