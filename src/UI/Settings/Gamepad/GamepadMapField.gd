tool
class_name GamepadMapField, "res://assets/icons/gamepad.svg"
extends HBoxContainer

export var action := ""
export var placeholder := "placeholder" setget _set_placeholder

var values := {}
var keymap_buttons := []

onready var default_button := $Default


func _ready() -> void:
	if Engine.editor_hint:
		return

	yield(owner, "ready")
	yield(get_tree(), "idle_frame")
	connect("focus_entered", self, "_on_Focus_entered")

	if action.empty():
		printerr("Action for %s is undefined" % get_name())
		return

	if not InputMap.has_action(action):
		InputMap.add_action(action)

	default_button.assign_with_constant(Config.values[owner.form.engine_file_section][InputManager.device][action][default_button.key])

	# register itself in to the form
	owner.form.data[action] = self


func reset() -> void:
	for button in keymap_buttons:
		button.assign_with_constant(
			Config.values[owner.form.engine_file_section][action][button.key]
		)


func unmap(scancode: int) -> void:
	for button in keymap_buttons:
		if button.assigned_to != EngineSettings.get_keyboard_or_mouse_key_from_scancode(scancode):
			continue
		button.clear()


func get_button_by_scancode(scancode: int) -> Button:
	for button in keymap_buttons:
		if button.assigned_to == EngineSettings.get_keyboard_or_mouse_key_from_scancode(scancode):
			return button
	return null


func apply_changes(key: String) -> void:
	var data_to_save := {}
	data_to_save[owner.form.engine_file_section] = {}
	data_to_save[owner.form.engine_file_section][action] = {}
	data_to_save[owner.form.engine_file_section][action][default_button.key] = default_button.assigned_to
	Config.save_file(data_to_save)


func change_button_focus_by_name(name: String) -> void:
	get_node(name).grab_focus()


func _set_placeholder(value: String) -> void:
	if not has_node("Default"):
		return
	placeholder = value
	$Default.text = placeholder


func _on_Focus_entered() -> void:
	$Default.grab_focus()
	Events.emit_signal("field_focus_entered", self)
