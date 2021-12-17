# Convert data to percentage
# Directly save value, there is no mapping
# with options
tool
class_name SliderField, "res://assets/icons/percent.svg"
extends Field

export var min_value := 0.0
export var max_value := 100.0
export var nb_of_step := 10

var _is_computing_from_negative := false
var _should_trigger_updater_callback_action := false
onready var slider := $HSlider


func _ready() -> void:
	yield(owner, "ready")

	if key.empty():
		printerr("%s's key is empty" % get_name())
		return

	connect("focus_entered", self, "_on_Focus_entered")
	slider.connect("focus_exited", self, "_on_Slider_focus_exited")
	slider.connect("value_changed", self, "_on_Value_changed")

	values.properties = EngineSettings.data[owner.form.engine_file_section][key]["properties"]
	
	updater.apply_on_save = false
	
	if abs(min_value) > max_value:
		_is_computing_from_negative = true
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = abs(max_value - min_value) / nb_of_step
	revert()


func reset() -> void:
	_should_trigger_updater_callback_action = false
	slider.value = EngineSettings.data[owner.form.engine_file_section][key].default
	apply()


func revert() -> void:
	slider.value = Config.values[owner.form.engine_file_section][key]
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
	Events.emit_signal("field_focus_entered", self)


func _on_Slider_focus_exited() -> void:
	Events.emit_signal("field_focus_exited", self)


func _on_Value_changed(value: float) -> void:
	$Value.text = String(percentage(value))
	values.key = value
	for key in values.properties:
		values.properties[key] = value

	updater.apply(values.properties, _should_trigger_updater_callback_action)

	# first load
	if not _should_trigger_updater_callback_action:
		_should_trigger_updater_callback_action = true
	else:
		self.is_pristine = false
	print_debug("%s has apply properties : %s" % [get_name(), values.properties])
