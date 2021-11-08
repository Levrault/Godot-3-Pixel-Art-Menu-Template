extends Button


func _ready():
	yield(owner, "ready")
	connect("pressed", self, "_on_Pressed")
	owner.form.connect("pristine_value_changed", self, "_on_Pristine_value_changed")
	visible = false
	focus_mode = FOCUS_NONE


func _on_Pressed() -> void:
	owner.form.save()


func _on_Pristine_value_changed(is_pristine: bool) -> void:
	visible = not is_pristine

	if is_pristine:
		focus_mode = FOCUS_NONE
		return

	yield(get_tree(), "idle_frame")
	focus_mode = FOCUS_ALL
