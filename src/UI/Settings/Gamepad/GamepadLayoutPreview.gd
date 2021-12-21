extends Control


func _ready():
	Events.connect("gamepad_layout_changed", self, "_on_Gamepad_layout")
	_on_Gamepad_layout()


func _on_Gamepad_layout() -> void:
	$VBoxContainer/Attack.text = Config.values.gamepad_bindind[InputManager.DEVICE_XBOX_CONTROLLER].attack.default
	$VBoxContainer/Evade.text = Config.values.gamepad_bindind[InputManager.DEVICE_XBOX_CONTROLLER].evade.default
	$VBoxContainer/Block.text = Config.values.gamepad_bindind[InputManager.DEVICE_XBOX_CONTROLLER].block.default
	$VBoxContainer/Jump.text = Config.values.gamepad_bindind[InputManager.DEVICE_XBOX_CONTROLLER].jump.default
	$VBoxContainer/Run.text = Config.values.gamepad_bindind[InputManager.DEVICE_XBOX_CONTROLLER].run.default
