tool
class_name KeyMapField, "res://assets/icons/keyboard.svg"
extends HBoxContainer

export var action := ""
export var required := true
export var alt_placeholder := "alt_placeholder" setget _set_alt_placeholder
export var placeholder := "placeholder" setget _set_placeholder

var values := {}
var keymap_buttons := []
var last_focused_button: Button = null
var button_to_focus: Button = null


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

	for child in get_children():
		if not child is Button:
			continue

		keymap_buttons.append(child)
		child.assign_with_constant(Config.values[owner.form.engine_file_section][action][child.key])

	button_to_focus = keymap_buttons[0]
	last_focused_button = keymap_buttons[0]
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
	owner.form.has_changed = true
	var data_to_save := {}
	for button in keymap_buttons:
		data_to_save[button.key] = button.assigned_to
	Config.save_field(owner.form.engine_file_section, action, data_to_save)


func change_button_focus_by_name(name: String) -> void:
	get_node(name).grab_focus()


func _set_placeholder(value: String) -> void:
	if not has_node("Default"):
		return
	placeholder = value
	$Default.text = placeholder


func _set_alt_placeholder(value: String) -> void:
	if not has_node("Alt"):
		return
	alt_placeholder = value
	$Alt.text = alt_placeholder


func _on_Focus_entered() -> void:
	button_to_focus.grab_focus()
	Events.emit_signal("field_focus_entered", self)
