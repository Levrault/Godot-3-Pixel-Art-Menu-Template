# Manage all fields with multiple options like hlist and dropdown
# e.g. engine.cfg
# ```
# window_mode = {
#     "default": "borderless",
#     "options": [ {
#         "key": "fullscreen",
#         "translation_key": "cfg.fullscreen",
#         "properties": {
#             "display/window/size/fullscreen": true,
#             "display/window/size/borderless": false,
#         }
#     }, {
#         "key": "borderless",
#         "translation_key": "cfg.borderless",
#         "properties": {
#             "display/window/size/fullscreen": false,
#             "display/window/size/borderless": true,
#         }
#     }, {
#         "key": "windowed",
#         "translation_key": "cfg.windowed",
#         "properties": {
#             "display/window/size/fullscreen": false,
#             "display/window/size/borderless": false,
#         }
#     } ]
# }
# ```
# @category: Field

tool
class_name FieldWithOptions, "res://assets/icons/field.svg"
extends Field

var selected_key := "" setget _set_selected_key
var items := []
var _index: int = 0
var _can_save_field := false  # prevent save on first load


func _ready() -> void:
	if Engine.editor_hint:
		return
	yield(owner, "ready")

	if key.empty():
		printerr("%s's key is empty" % get_name())
		return

	if not EngineSettings.data.has(owner.form.engine_file_section):
		printerr("Form section %s is not defined in Config" % owner.form.engine_file_section)
		return

	if not EngineSettings.data[owner.form.engine_file_section].has(key):
		printerr("%s has no options associated to key %s" % [get_name(), key])
		return

	if filter != null:
		items = filter.apply(EngineSettings.data[owner.form.engine_file_section][key]["options"])
		return
	items = EngineSettings.data[owner.form.engine_file_section][key]["options"]


# Check if the field has the correct data to be created
# if not, reset to engine`s default value
# if the data are corrects, load last saved data
# Delegue reset calling by inherited child
func initialize() -> void:
	var config_data = Config.values[owner.form.engine_file_section][key]
	var is_compatible_with_field := true
	var has_been_found := false

	# bad type
	if typeof(config_data) != TYPE_STRING:
		is_compatible_with_field = false

	# not an existing option
	if is_compatible_with_field:
		for option in EngineSettings.data[owner.form.engine_file_section][key]["options"]:
			if option.key == config_data:
				has_been_found = true

	if not has_been_found or not is_compatible_with_field:
		if not is_compatible_with_field:
			printerr(
				(
					"Saved data of %s is invalid, should be a string, found %s instead"
					% [get_name(), config_data]
				)
			)
		if not has_been_found:
			printerr(
				(
					"Saved data of %s doesn't exist in engine.cfg, data is %s instead"
					% [get_name(), config_data]
				)
			)
		reset()
		Config.save_field(owner.form.engine_file_section, key, selected_key)
		return


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	self.selected_key = EngineSettings.data[owner.form.engine_file_section][key].default
	_compute_index()
	apply()


# Change to user config value
# Used to load the last saved data
func revert() -> void:
	.revert()
	if not EngineSettings.data.has(owner.form.engine_file_section):
		printerr("Form section %s is not defined in Config" % owner.form.engine_file_section)
		return

	if not EngineSettings.data[owner.form.engine_file_section].has(key):
		printerr("%s has no options associated to key %s" % [get_name(), key])
		return
	# get default value from engine
	self.selected_key = Config.values[owner.form.engine_file_section][key]
	_compute_index()
	apply()


func _set_selected_key(text: String) -> void:
	selected_key = text
	values = EngineSettings.get_option(owner.form.engine_file_section, key, text)
	if _can_save_field:
		Config.save_field(owner.form.engine_file_section, key, selected_key)
	else:
		_can_save_field = true
	updater.apply(values.properties, true)


func _compute_index() -> void:
	# set index
	var f_index := 0
	for item in items:
		if item.key != selected_key:
			f_index += 1
			continue
		_index = f_index
