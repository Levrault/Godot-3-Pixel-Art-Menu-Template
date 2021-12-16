class_name Form, "res://assets/icons/form.svg"
extends Node

signal pristine_value_changed(value)

export var engine_file_section := ""

var data := {}
var is_pristine := true setget _set_is_pristine

onready var confirm_dialog := $ConfirmationDialog


func _ready() -> void:
	confirm_dialog.get_close_button().hide()
	confirm_dialog.get_ok().connect("pressed", self, "_on_Ok_dialog_pressed")
	confirm_dialog.get_cancel().connect("pressed", self, "_on_Cancel_dialog_pressed")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_invalid():
		invalid_callback()
		return


func reset() -> void:
	for key in data:
		data[key].reset()


func revert() -> void:
	for key in data:
		if data[key].is_pristine:
			continue
		data[key].revert()


func update_pristine() -> void:
	var result := true
	for key in data:
		if not data[key].is_pristine:
			result = false
	self.is_pristine = result


func apply_changes(values: Dictionary) -> void:
	var data_to_save := {}
	data_to_save[engine_file_section] = {}
	for key in values:
		data_to_save[engine_file_section][key] = values[key].values.key
	Config.save_file(data_to_save)


func save() -> void:
	for key in data:
		if data[key].is_pristine:
			continue
		if data[key].updater == null:
			continue
		data[key].updater.apply(data[key].values.properties)

	apply_changes(data)
	self.is_pristine = true


func invalid_callback() -> void:
	Events.emit_signal("navigation_disabled")
	Events.emit_signal("overlay_displayed")
	confirm_dialog.show()
	confirm_dialog.get_ok().grab_focus()


func is_invalid() -> bool:
	return owner.is_current_route and not is_pristine


func _set_is_pristine(value: bool) -> void:
	is_pristine = value
	emit_signal("pristine_value_changed", value)


func _on_Ok_dialog_pressed() -> void:
	save()
	Events.emit_signal("overlay_hidden")
	Events.emit_signal("navigation_enabled")
	Menu.navigate_to(Menu.history.pop_back())


func _on_Cancel_dialog_pressed() -> void:
	revert()
	Events.emit_signal("overlay_hidden")
	Events.emit_signal("navigation_enabled")
	Menu.navigate_to(Menu.history.pop_back())
