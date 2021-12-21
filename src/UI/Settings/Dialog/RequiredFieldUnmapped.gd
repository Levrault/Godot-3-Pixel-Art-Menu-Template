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

	$MarginContainer/VBoxContainer/Message.text = tr("ui_required_action_unmapped").format(
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
