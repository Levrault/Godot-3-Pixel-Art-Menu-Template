extends Control

onready var attack = $VBoxContainer/Attack
onready var evade = $VBoxContainer/Evade
onready var block = $VBoxContainer/Block
onready var jump = $VBoxContainer/Jump
onready var run = $VBoxContainer/Run


func _ready():
	yield(owner, "ready")
	Events.connect("gamepad_layout_changed", self, "_on_Gamepad_layout")
	_on_Gamepad_layout()


func _on_Gamepad_layout() -> void:
	var layout = Config.values[owner.form.engine_file_section].gamepad_layout
	var device = (
		InputManager.device
		if InputManager.is_using_gamepad()
		else InputManager.DEVICE_XBOX_CONTROLLER
	)

	if layout == "custom":
		attack.text = "attack: " + Config.values.gamepad_bindind[device].attack.default
		evade.text = "evade: " + Config.values.gamepad_bindind[device].evade.default
		block.text = "block: " + Config.values.gamepad_bindind[device].block.default
		jump.text = "jump: " + Config.values.gamepad_bindind[device].jump.default
		run.text = "run: " + Config.values.gamepad_bindind[device].run.default
	else:
		attack.text = "attack: " + EngineSettings.gamepad[device][layout].attack.default
		evade.text = "evade: " + EngineSettings.gamepad[device][layout].evade.default
		block.text = "block: " + EngineSettings.gamepad[device][layout].block.default
		jump.text = "jump: " + EngineSettings.gamepad[device][layout].jump.default
		run.text = "run: " + EngineSettings.gamepad[device][layout].run.default
