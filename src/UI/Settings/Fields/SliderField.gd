# Slider field
# Directly change a number value (float, int etc.)
#
# A timer is used to debounce the save process and
# prevent too many call on the save function
#
# e.g. engine.cfg
# ```
# ui_volume = {
#     "default": 0,
#     "properties": {
#         "UI": 0
#     }
# }
# ```
# @category: Field
tool
class_name SliderField, "res://assets/icons/percent.svg"
extends Field

const FLOAT_TEMPLATE := "%.1f"
const INT_TEMPLATE := "%d"

export var min_value := 0.0
export var max_value := 100.0
export var auto_compute_step := true
export var nb_of_step := 10
export var step := 1.0
export var percentage_mode := false
export var rounded := false
export var placeholder := "placeholder" setget _set_placeholder

# does our min value is negative
var _is_computing_from_negative := false
var _string_template := FLOAT_TEMPLATE

onready var slider := $HSlider
onready var value_label := $Value
onready var debounce_timer := $DebounceTimer


func _ready() -> void:
	if Engine.editor_hint:
		return

	yield(owner, "ready")

	if key.empty():
		printerr("%s's key is empty" % get_name())
		return

	values.properties = EngineSettings.data[owner.form.engine_file_section][key]["properties"]
	if abs(min_value) > max_value:
		_is_computing_from_negative = true
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = abs(max_value - min_value) / nb_of_step if auto_compute_step else step

	if rounded:
		_string_template = INT_TEMPLATE

	initialize()
	connect("focus_entered", self, "_on_Focus_entered")
	slider.connect("focus_exited", self, "emit_signal", ["field_focus_exited"])
	slider.connect("value_changed", self, "_on_Value_changed")
	debounce_timer.connect("timeout", self, "_on_Timeout")


# Check if the field has the correct data to be created
# if not, reset to engine`s default value
# if the data are corrects, load last saved data
func initialize() -> void:
	var config_data = Config.values[owner.form.engine_file_section][key]
	var is_compatible_with_field := true
	var is_in_range := true

	# bad type
	if typeof(config_data) != TYPE_REAL and typeof(config_data) != TYPE_INT:
		is_compatible_with_field = false
	elif config_data < min_value or config_data > max_value:
		# out of bound
		is_in_range = false

	if not is_compatible_with_field or not is_in_range:
		if not is_compatible_with_field:
			printerr(
				(
					"Saved data of %s is invalid, should be a string, found %s instead"
					% [get_name(), config_data]
				)
			)
		if not is_in_range:
			printerr(
				(
					"Saved data of %s is not a value between [%s, %s], value is %s"
					% [get_name(), min_value, max_value, config_data]
				)
			)
		var value: float = EngineSettings.data[owner.form.engine_file_section][key].default
		slider.value = value
		values.key = value
		_set_value_text(value);
		Config.save_field(owner.form.engine_file_section, key, values.key)
		apply()
		return
	revert()


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	slider.disconnect("value_changed", self, "_on_Value_changed")

	var value: float = EngineSettings.data[owner.form.engine_file_section][key].default
	slider.value = value
	values.key = value
	_set_value_text(value);
	for key in values.properties:
		values.properties[key] = value
	Config.save_field(owner.form.engine_file_section, key, values.key)
	apply()

	slider.call_deferred("connect", "value_changed", self, "_on_Value_changed")


# Change to user config value
# Used to load the last saved data
func revert() -> void:
	var value: float = Config.values[owner.form.engine_file_section][key]
	slider.value = value
	values.key = value
	for key in values.properties:
		values.properties[key] = value
	_set_value_text(value);
	apply()


func percentage(value) -> float:
	if _is_computing_from_negative:
		return (abs(min_value) - abs(value)) * 100 / abs(min_value)
	return abs(abs(min_value) - abs(value)) * 100 / abs(max_value)


func _set_value_text(value: float) -> void:
	if percentage_mode:
		value_label.text = INT_TEMPLATE % percentage(value) + "%"
		return
	value_label.text = _string_template % value


func _set_placeholder(value: String) -> void:
	placeholder = value
	$Value.text = placeholder


func _on_Focus_entered() -> void:
	slider.grab_focus()
	emit_signal("field_focus_entered")


func _on_Value_changed(value: float) -> void:
	_set_value_text(value);
	values.key = value
	for key in values.properties:
		values.properties[key] = value

	updater.apply(values.properties, true)

	emit_signal("field_item_selected", values.key)

	# first load
	self.is_pristine = false
	debounce_timer.start()
	print_debug("%s has apply properties : %s" % [get_name(), values.properties])


func _on_Timeout() -> void:
	Config.save_field(owner.form.engine_file_section, key, values.key)
