class_name Form, "res://assets/icons/form.svg"
extends Node

signal pristine_value_changed(value)

export var engine_file_section := ""

var data := {}
var is_pristine := true setget _set_is_pristine

onready var confirm_dialog := $ConfirmationDialog


func _ready() -> void:
	confirm_dialog.get_ok().connect("pressed", self, "_on_Ok_dialog_pressed")
	confirm_dialog.get_cancel().connect("pressed", self, "_on_Cancel_dialog_pressed")


func revert() -> void:
	for key in data:
		if data[key].is_pristine:
			continue
		data[key].revert()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and owner.is_current_route and not is_pristine:
		Events.emit_signal("navigation_disabled")
		confirm_dialog.show()
		confirm_dialog.get_ok().grab_focus()
		return


func apply_changes(values: Dictionary) -> void:
	var data_to_save := {}
	data_to_save[engine_file_section] = {}
	for key in values:
		data_to_save[engine_file_section][key] = values[key].values.key
		values[key].revert()
	Config.save(data_to_save)


func save() -> void:
	for key in data:
		if data[key].is_pristine:
			continue
		if data[key].updater == null:
			continue
		data[key].updater.apply(data[key].values.properties)

	apply_changes(data)
	self.is_pristine = true


func _set_is_pristine(value: bool) -> void:
	is_pristine = value
	emit_signal("pristine_value_changed", value)


func _on_Ok_dialog_pressed() -> void:
	save()
	Events.emit_signal("navigation_enabled")
	Menu.navigate_to(Menu.history.pop_back())


func _on_Cancel_dialog_pressed() -> void:
	revert()
	Events.emit_signal("navigation_enabled")
	Menu.navigate_to(Menu.history.pop_back())
