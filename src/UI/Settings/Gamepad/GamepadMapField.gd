tool
class_name GamepadMapField, "res://assets/icons/gamepad.svg"
extends HBoxContainer

export var action := ""
export var required := true
export var placeholder := "placeholder" setget _set_placeholder

var values := {}

onready var default_button := $Default


func _ready() -> void:
	if Engine.editor_hint:
		return

	yield(owner, "ready")
	yield(get_tree(), "idle_frame")
	connect("focus_entered", self, "_on_Focus_entered")
	owner.connect("navigation_finished", self, "_on_Navigation_finished")

	if action.empty():
		printerr("Action for %s is undefined" % get_name())
		return

	if not InputMap.has_action(action):
		InputMap.add_action(action)

	default_button.assign_with_constant(
		Config.values[owner.form.engine_file_section][InputManager.device][action][default_button.key]
	)
	default_button.type = InputManager.device

	# register itself in to the form
	owner.form.data[action] = self


func reset() -> void:
	default_button.assign_with_constant(
		Config.values[owner.form.engine_file_section][InputManager.device][action][default_button.key]
	)


func unmap(scancode: int) -> void:
	default_button.clear()


func _set_placeholder(value: String) -> void:
	if not has_node("Default"):
		return
	placeholder = value
	$Default.text = placeholder


func _on_Focus_entered() -> void:
	$Default.grab_focus()
	Events.emit_signal("field_focus_entered", self)


func _on_Navigation_finished() -> void:

	if InputManager.device == InputManager.DEVICE_KEYBOARD:
		default_button.assign_with_constant(
			Config.values[owner.form.engine_file_section][InputManager.DEVICE_GENERIC][action][default_button.key]
		)
	else:
		default_button.assign_with_constant(
			Config.values[owner.form.engine_file_section][InputManager.device][action][default_button.key]
		)
	default_button.type = InputManager.device
	owner.form.device = InputManager.device
