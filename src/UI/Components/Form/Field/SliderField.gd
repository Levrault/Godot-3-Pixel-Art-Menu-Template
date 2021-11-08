# Convert data to percentage
# Directly save value, there is no mapping
# with options
tool
class_name SliderField, "res://assets/icons/percent.svg"
extends Field

export var min_value := 0.0
export var max_value := 100.0
export var nb_of_step := 10

var compute_from_negative := false
onready var slider := $HSlider


func _ready() -> void:
	yield(owner, "ready")

	connect("focus_entered", self, "_on_Focus_entered")
	slider.connect("focus_exited", self, "_on_Slider_focus_exited")
	slider.connect("value_changed", self, "_on_Value_changed")

	values.properties = EngineSettings.data[owner.form.engine_file_section][key]["properties"]

	if abs(min_value) > max_value:
		compute_from_negative = true
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = abs(max_value - min_value) / nb_of_step
	revert()


func reset() -> void:
	values.properties = EngineSettings.data[owner.form.engine_file_section][key].default
	apply()


func revert() -> void:
	slider.value = Config.values[owner.form.engine_file_section][key]
	apply()


func percentage(value) -> float:
	var total = max_value if not compute_from_negative else abs(min_value)
	return (abs(total) - abs(value)) * 100 / abs(total)


func _set_placeholder(value: String) -> void:
	placeholder = value
	$Value.text = placeholder


func _on_Focus_entered() -> void:
	slider.grab_focus()
	emit_signal("field_focus_entered")


func _on_Slider_focus_exited() -> void:
	emit_signal("field_focus_exited")


func _on_Value_changed(value: float) -> void:
	$Value.text = String(percentage(value))
	values.key = value	
	for key in values.properties:
		values.properties[key] = value

	print_debug("%s has apply properties : %s" % [get_name(), values.properties])
	updater.apply(values.properties, true)
