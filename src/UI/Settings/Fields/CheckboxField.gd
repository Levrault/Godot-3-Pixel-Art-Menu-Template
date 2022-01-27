# Checkbox fields
# Works with 2 values, "checked" and "unchecked"
# Trigger error if the engine.cfg isn't mapped with those values
#
# e.g. engine.cfg
# ```
# use_vsync = {
#     "default": "checked",
#     "checked": {
#         "key": true,
#         "properties": {
#             "display/window/size/use_vsync": true
#         }
#     },
#     "unchecked": {
#         "key": false,
#         "properties": {
#             "display/window/size/use_vsync": false
#         }
#     }
# }
# ```
# @category: Field
tool
class_name CheckboxField, "res://assets/icons/check-square.svg"
extends Field

const CHECKED := "checked"
const UNCHECKED := "unchecked"

var selected_key := ""

onready var checkbox := $CheckBox


func _ready() -> void:
	if Engine.editor_hint:
		return
	yield(owner, "ready")
	if key.empty():
		printerr("%s's key is empty" % get_name())
		return

	initialize()
	connect("focus_entered", self, "_on_Focus_entered")
	checkbox.connect("toggled", self, "_on_Toggled")
	checkbox.connect("focus_exited", self, "emit_signal", ["field_focus_exited"])


# Check if the field has the correct data to be created
# if not, reset to engine`s default value
# if the data are corrects, load last saved data
func initialize() -> void:
	var config_data = Config.values[owner.form.engine_file_section][key]
	if config_data != CHECKED and config_data != UNCHECKED:
		printerr(
			(
				"Saved data of %s are invalid, should be [%s, %s], found %s instead"
				% [get_name(), CHECKED, UNCHECKED, config_data]
			)
		)
		reset()
		return
	revert()


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	selected_key = EngineSettings.data[owner.form.engine_file_section][key].default
	values = EngineSettings.data[owner.form.engine_file_section][key][selected_key]
	checkbox.pressed = values.key
	Config.save_field(owner.form.engine_file_section, key, selected_key)
	apply()


# Change to user config value
# Used to load the last saved data
func revert() -> void:
	selected_key = Config.values[owner.form.engine_file_section][key]
	values = EngineSettings.data[owner.form.engine_file_section][key][selected_key]
	checkbox.pressed = values.key
	apply()


func _on_Toggled(button_pressed: bool) -> void:
	selected_key = CHECKED if button_pressed else UNCHECKED
	values = EngineSettings.data[owner.form.engine_file_section][key][selected_key]
	owner.form.has_changed = true
	Config.save_field(owner.form.engine_file_section, key, selected_key)
	emit_signal("field_item_selected", button_pressed)


func _on_Focus_entered() -> void:
	checkbox.grab_focus()
	emit_signal("field_focus_entered")
