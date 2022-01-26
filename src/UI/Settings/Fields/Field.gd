# Generic field class
# Contains all basic functions a field needs
# Get Updater and filter
# Register fields into the owner's form
# @category: Field
tool
class_name Field, "res://assets/icons/field.svg"
extends HBoxContainer

signal field_focus_entered
signal field_focus_exited
signal field_item_selected(item)

export var key := ""
export var description := ""

var values := {}
var is_pristine := true setget _set_is_pristine

onready var updater := get_node_or_null("Updater")
onready var filter := get_node_or_null("Filter")


func _ready() -> void:
	if Engine.editor_hint:
		return

	if owner:
		yield(owner, "ready")

	if not updater:
		printerr("Field %s from %s has no updater" % [key, owner.get_name()])
		return

	# register itself in to the form
	owner.form.data[key] = self


# Check if the field has the correct data to be created
# if not, reset to engine`s default value
# if the data are corrects, load last saved data
func initialize() -> void:
	printerr("%s does not have a custom initilize function" % owner.get_name())
	revert()


# Sent data to the updater (wihout the trigger action callback)
func apply() -> void:
	self.is_pristine = true
	updater.apply(values.properties, false)


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	if not EngineSettings.data.has(owner.form.engine_file_section):
		printerr("Form section %s has not been set is form node of %s" % [key, owner.get_name()])
		return

	if not EngineSettings.data[owner.form.engine_file_section].has(key):
		printerr("Field %s from %s is not set in engine.cfg" % [key, owner.get_name()])
		return


# Change to user config value
# Used to load the last saved data
func revert() -> void:
	if not Config.values.has(owner.form.engine_file_section):
		printerr("%s section doesn't exist in config file" % owner.form.engine_file_section)
		return

	if not Config.values[owner.form.engine_file_section].has(key):
		printerr("%s/%s doesn't exist in config file" % [owner.form.engine_file_section, key])
		return


func _set_is_pristine(value: bool) -> void:
	is_pristine = value

	if not is_pristine and not owner.form.has_changed:
		owner.form.has_changed = true
