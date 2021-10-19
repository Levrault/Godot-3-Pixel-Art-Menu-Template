# Generic field class
# signals
#	field_focus_entered	- use by fieldset (to hightlight the field)
#	field_focus_exited 	- use by fieldset (to remove hightlight from the field)
tool
class_name Field, "res://assets/icons/field.svg"
extends HBoxContainer

signal pristine_value_changed(value)
signal field_focus_entered
signal field_focus_exited

export var key := ""
export var placeholder := "placeholder" setget _set_placeholder

var selected_key := "" setget _set_selected_key
var values := {}
var is_pristine := true setget _set_is_pristine
var items := []
var _index: int = 0

onready var updater := get_node_or_null("Updater")


func _ready() -> void:
	if Engine.editor_hint:
		return

	yield(owner, "ready")
	Events.connect("config_file_saved", self, "revert")
	connect("focus_entered", self, "_on_Focus_toggle", [true])
	connect("focus_exited", self, "_on_Focus_toggle", [false])

	if not EngineSettings.data.has(owner.form.engine_file_section):
		printerr("Form section %s has not been set is form node of %s" % [key, owner.get_name()])
		return
	if not EngineSettings.data[owner.form.engine_file_section].has(key):
		printerr("Field %s from %s is not set in engine.cfg" % [key, owner.get_name()])
		return

	# get options from engine
	items = EngineSettings.data[owner.form.engine_file_section][key]["options"]
	owner.form.data[key] = self


func reset() -> void:
	updater.apply(values.properties, false)


func revert() -> void:
	if not Config.values.has(owner.form.engine_file_section):
		printerr("%s section doesn't exist in config file" % owner.form.engine_file_section)
		return

	if not Config.values[owner.form.engine_file_section].has(key):
		printerr("%s/%s doesn't exist in config file" % [owner.form.engine_file_section, key])
		return

	# get default value from engine
	self.selected_key = Config.values[owner.form.engine_file_section][key]
	self.is_pristine = true

	# set index
	var f_index := 0
	for item in items:
		if item.key != selected_key:
			f_index += 1
			continue
		_index = f_index

	if updater:
		updater.apply(values.properties, false)


func _set_placeholder(value: String) -> void:
	pass


func _set_is_pristine(value: bool) -> void:
	is_pristine = value
	emit_signal("pristine_value_changed", value)


func _set_selected_key(text: String) -> void:
	selected_key = text
	values = EngineSettings.get_option(owner.form.engine_file_section, key, text)

	if not is_pristine:
		owner.form.is_pristine = false


func _on_Focus_toggle(is_focused: bool) -> void:
	if is_focused:
		emit_signal("field_focus_entered")
		return
	emit_signal("field_focus_exited")
	print("%s has focus" % [get_name()])
