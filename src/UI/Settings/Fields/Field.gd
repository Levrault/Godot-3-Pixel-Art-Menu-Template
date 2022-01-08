# Generic field class
# export
#	key - related key from ConfigFile
#	placeholder - just an optional placeholder to simulate data in the editor's UI
# signals
#	field_focus_entered	- use by fieldset (to hightlight the field)
#	field_focus_exited 	- use by fieldset (to remove hightlight from the field)
tool
class_name Field, "res://assets/icons/field.svg"
extends HBoxContainer

signal pristine_value_changed(value)

export var key := ""
export var description := ""

var values := {}
var is_pristine := true setget _set_is_pristine

onready var updater := get_node_or_null("Updater")


func _ready() -> void:
	if Engine.editor_hint:
		return

	if owner:
		yield(owner, "ready")

	if not updater:
		printerr("Field %s from %s has no updater" % [key, owner.get_name()])
		return

	connect("focus_entered", self, "_on_Focus_toggle", [true])
	connect("focus_exited", self, "_on_Focus_toggle", [false])

	# register itself in to the form
	owner.form.data[key] = self


func apply() -> void:
	self.is_pristine = true
	updater.apply(values.properties, false)


# Reset to Engine`s default value from Engine file
func reset() -> void:
	if not EngineSettings.data.has(owner.form.engine_file_section):
		printerr("Form section %s has not been set is form node of %s" % [key, owner.get_name()])
		return

	if not EngineSettings.data[owner.form.engine_file_section].has(key):
		printerr("Field %s from %s is not set in engine.cfg" % [key, owner.get_name()])
		return


# Revert to previously saved data from ConfigFile
func revert() -> void:
	if not Config.values.has(owner.form.engine_file_section):
		printerr("%s section doesn't exist in config file" % owner.form.engine_file_section)
		return

	if not Config.values[owner.form.engine_file_section].has(key):
		printerr("%s/%s doesn't exist in config file" % [owner.form.engine_file_section, key])
		return


func _set_is_pristine(value: bool) -> void:
	is_pristine = value
	emit_signal("pristine_value_changed", value)

	if not is_pristine and not owner.form.has_changed:
		owner.form.has_changed = true


func _on_Focus_toggle(is_focused: bool) -> void:
	if is_focused:
		Events.emit_signal("field_focus_entered", self)
		return
	Events.emit_signal("field_focus_exited", self)
