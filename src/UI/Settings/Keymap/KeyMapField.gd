# Regroup KeymapButton and manage data transfer
# and user interaction
# @category: Keyboard, Rebind
tool
class_name KeyMapField, "res://assets/icons/keyboard.svg"
extends HBoxContainer

signal field_item_focused(index)
signal field_item_selected(item)
signal field_focus_entered
signal field_focus_exited
signal input_focus_entered
signal input_focus_exited

export var action := ""
export var description := ""
export var required := true
export var alt_placeholder := "alt_placeholder" setget _set_alt_placeholder
export var placeholder := "placeholder" setget _set_placeholder

var values := {}
var keymap_buttons := []
var is_inner_navigation_activated := false
var last_focused_button: Button = null setget _set_last_focused_button, _get_last_focused_button
var button_to_focus: Button = null


func _ready() -> void:
	if Engine.editor_hint:
		return

	yield(owner, "ready")
	yield(get_tree(), "idle_frame")

	connect("focus_entered", self, "emit_signal", ["field_focus_entered"])
	connect(
		"field_focus_entered",
		owner.get_node("KeyboardRebindHelper"),
		"_on_Field_focus_entered",
		[self]
	)

	if action.empty():
		printerr("Action for %s is undefined" % get_name())
		return

	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for child in get_children():
		if not child is Button:
			continue

		child.connect(
			"focus_entered",
			owner.get_node("KeyboardRebindHelper"),
			"_on_Button_focus_entered",
			[self]
		)
		keymap_buttons.append(child)
		child.assign_with_constant(Config.values[owner.form.engine_file_section][action][child.key])

	# register itself in to the form
	owner.form.data[action] = self


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	for button in keymap_buttons:
		button.assign_with_constant(
			Config.values[owner.form.engine_file_section][action][button.key]
		)


# remove current input
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
	emit_signal("field_item_selected", key)


func change_button_focus_by_name(name: String) -> void:
	get_node(name).grab_focus()


func inner_navigation(next_button: Button) -> void:
	if next_button == last_focused_button:
		return
	self.last_focused_button = next_button
	if is_inner_navigation_activated:
		emit_signal("field_item_focused", next_button)


func _set_last_focused_button(value: Button) -> void:
	last_focused_button = value
	if last_focused_button != null:
		last_focused_button.grab_focus()


func _get_last_focused_button() -> Button:
	if last_focused_button == null:
		return keymap_buttons[0]
	return last_focused_button


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
