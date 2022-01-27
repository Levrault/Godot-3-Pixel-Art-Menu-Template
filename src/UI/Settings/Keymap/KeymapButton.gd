# Keyboard button
# Trigger bindind action when pressed
# @category: Keyboard, Rebind
extends Button

export var key := ""

var assigned_to := ""
var type := "keyboard"


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")
	connect("focus_entered", owner, "inner_navigation", [self])
	connect("mouse_entered", owner, "inner_navigation", [self])


# Change to Engine`s default value (engine.cfg)
func assign_with_constant(value: String) -> void:
	if value.empty():
		clear()
		return
	assigned_to = value

	type = "keyboard" if EngineSettings.keylist["keyboard"].has(value) else "mouse"
	if type == "keyboard":
		text = OS.get_scancode_string(EngineSettings.keylist[type][value])
		var input_event_key = InputEventKey.new()
		input_event_key.set_scancode(EngineSettings.keylist[type][value])
		InputMap.action_add_event(owner.action, input_event_key)
	else:
		text = tr(EngineSettings.get_mouse_button_string(assigned_to))
		var input_event_mouse = InputEventMouseButton.new()
		input_event_mouse.set_button_index(EngineSettings.keylist[type][value])
		InputMap.action_add_event(owner.action, input_event_mouse)
	owner.values[key] = EngineSettings.keylist[type][value]


# Using a scancode for assignation
func assign_with_scancode(value: int) -> void:
	assign_with_constant(EngineSettings.get_keyboard_or_mouse_key_from_scancode(value))


func clear() -> void:
	if owner.values.has(key):
		if EngineSettings.keylist["keyboard"].has(assigned_to):
			var input_event_key = InputEventKey.new()
			input_event_key.set_scancode(owner.values[key])
			InputMap.action_erase_event(owner.action, input_event_key)
		else:
			var input_event_mouse = InputEventMouseButton.new()
			input_event_mouse.set_button_index(owner.values[key])
			InputMap.action_erase_event(owner.action, input_event_mouse)
	text = "_"
	assigned_to = ""
	owner.values[key] = -1


func _on_Pressed() -> void:
	Events.emit_signal("key_listening_started", owner, self, owner.values[key])
	release_focus()
