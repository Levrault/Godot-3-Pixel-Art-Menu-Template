# Convert data to percentage
# Directly save value, there is no mapping
# with options
tool
class_name SliderField, "res://assets/icons/percent.svg"
extends Field

export var min_value := 0.0
export var max_value := 100.0
export var nb_of_step := 10
export var percentage_mode := false
export var placeholder := "placeholder" setget _set_placeholder

var _is_computing_from_negative := false

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
	slider.step = abs(max_value - min_value) / nb_of_step

	initialize()
	connect("focus_entered", self, "_on_Focus_entered")
	slider.connect("focus_exited", self, "emit_signal", ["field_focus_exited"])
	slider.connect("value_changed", self, "_on_Value_changed")
	debounce_timer.connect("timeout", self, "_on_Timeout")


func initialize() -> void:
	var config_data = Config.values[owner.form.engine_file_section][key]
	var is_compatible_with_field := true
	var is_in_range := true

	# bad type
	if typeof(config_data) != TYPE_REAL and typeof(config_data) != TYPE_INT:
		is_compatible_with_field = false

	# out of bound
	if config_data < min_value or config_data > max_value:
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
		value_label.text = "%d" % percentage(value) + "%" if percentage_mode else "%.1f" % value
		Config.save_field(owner.form.engine_file_section, key, values.key)
		apply()
		return
	revert()


func reset() -> void:
	slider.disconnect("value_changed", self, "_on_Value_changed")

	var value: float = EngineSettings.data[owner.form.engine_file_section][key].default
	slider.value = value
	values.key = value
	value_label.text = "%d" % percentage(value) + "%" if percentage_mode else "%.1f" % value
	Config.save_field(owner.form.engine_file_section, key, values.key)
	apply()

	slider.call_deferred("connect", "value_changed", self, "_on_Value_changed")


func revert() -> void:
	var value: float = Config.values[owner.form.engine_file_section][key]
	slider.value = value
	values.key = value
	value_label.text = "%d" % percentage(value) + "%" if percentage_mode else "%.1f" % value
	apply()


func percentage(value) -> float:
	if _is_computing_from_negative:
		return (abs(min_value) - abs(value)) * 100 / abs(min_value)
	return abs(abs(min_value) - abs(value)) * 100 / abs(max_value)


func _set_placeholder(value: String) -> void:
	placeholder = value
	$Value.text = placeholder


func _on_Focus_entered() -> void:
	slider.grab_focus()
	emit_signal("field_focus_entered")


func _on_Value_changed(value: float) -> void:
	value_label.text = "%d" % percentage(value) + "%" if percentage_mode else "%.1f" % value
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
