tool
class_name FieldWithOptions, "res://assets/icons/field.svg"
extends Field

var selected_key := "" setget _set_selected_key
var items := []
var _index: int = 0


func _ready() -> void:
	yield(owner, "ready")
	items = EngineSettings.data[owner.form.engine_file_section][key]["options"]
	revert()


func reset() -> void:
	self.selected_key = EngineSettings.data[owner.form.engine_file_section][key]
	_compute_index()
	apply()


func revert() -> void:
	.revert()
	# get default value from engine
	self.selected_key = Config.values[owner.form.engine_file_section][key]
	_compute_index()
	apply()


func _set_selected_key(text: String) -> void:
	selected_key = text
	values = EngineSettings.get_option(owner.form.engine_file_section, key, text)


func _compute_index() -> void:
	# set index
	var f_index := 0
	for item in items:
		if item.key != selected_key:
			f_index += 1
			continue
		_index = f_index


