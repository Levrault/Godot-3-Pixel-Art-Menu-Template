extends WindowDialog

onready var ok_btn := $MarginContainer/VBoxContainer/HBoxContainer/Ok


func _ready() -> void:
	get_close_button().hide()
	ok_btn.connect("pressed", self, "_on_Ok_pressed")


func set_message(unmapped_fields := []) -> void:
	var actions := ""
	var separator := ", "
	for field in unmapped_fields:
		actions += field.action + separator
	actions = actions.left(actions.length() - separator.length())

	# plural/singular
	if unmapped_fields.size() > 1:
		window_title = tr("rebind.required_multi_actions_unmapped_title")
		$MarginContainer/VBoxContainer/Message.text = tr("rebind.required_multi_actions_unmapped").format(
			{actions = actions}
		)
	else:
		window_title = tr("rebind.required_single_action_unmapped_title")
		$MarginContainer/VBoxContainer/Message.text = tr("rebind.required_single_action_unmapped").format(
			{actions = actions}
		)


func show() -> void:
	Events.emit_signal("overlay_displayed")
	visible = true
	ok_btn.call_deferred("grab_focus")


func _on_Ok_pressed() -> void:
	hide()
	Events.emit_signal("overlay_hidden")
	Events.emit_signal("navigation_enabled")
	owner.focus_default_field()
