# Regroup GamepadButton and manage data transfer
# and user interaction
# @category: Gamepad, Rebind
tool
class_name GamepadMapField, "res://assets/icons/gamepad.svg"
extends HBoxContainer

signal field_item_selected(item)
signal field_focus_entered
signal field_focus_exited

export var action := ""
export var description := ""
export var required := true
export var placeholder := "" setget _set_placeholder

var values := {}

onready var default_button := $Default


func _ready() -> void:
	if Engine.editor_hint:
		return

	yield(owner, "ready")
	yield(get_tree(), "idle_frame")
	connect("focus_entered", self, "_on_Focus_entered")
	default_button.connect("focus_exited", self, "emit_signal", ["field_focus_exited"])
	owner.connect("navigation_finished", self, "_on_Navigation_finished")

	if action.empty():
		printerr("Action for %s is undefined" % get_name())
		return

	if not InputMap.has_action(action):
		InputMap.add_action(action)

	# register itself in to the form
	owner.form.data[action] = self


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	default_button.assign_with_constant(
		Config.values[owner.form.engine_file_section][InputManager.default_gamepad][action][default_button.key]
	)


# remove current input
func unmap(scancode: int) -> void:
	default_button.clear()


func _set_placeholder(value: String) -> void:
	if not has_node("Default"):
		return
	placeholder = value
	$Default.text = placeholder


func _on_Focus_entered() -> void:
	default_button.grab_focus()
	emit_signal("field_focus_entered")


func _on_Navigation_finished() -> void:
	var device := ""
	if InputManager.is_using_gamepad():
		device = InputManager.device
		default_button.assign_with_constant(
			Config.values[owner.form.engine_file_section][device][action][default_button.key]
		)
	else:
		device = InputManager.default_gamepad
		default_button.assign_with_constant(
			Config.values[owner.form.engine_file_section][device][action][default_button.key]
		)
	default_button.type = device
	owner.form.device = device
