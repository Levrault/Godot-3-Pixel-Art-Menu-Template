# Warm user to confirm a value
# Should be use for field that have a direct and instant impact on the visual
# Rollback to previous field value if the user doesn't confirm after X seconds
# Rollback to previous field value if the user cancel
# @category: Dialog
extends WindowDialog

# related field
export (NodePath) var field_path = ""
# time before self-closing & cancelling value
export var default_countdown := 15

var _field: Field = null
var _countdown := default_countdown

onready var timer := $Timer
onready var countdown_label := $MarginContainer/VBoxContainer/Countdown
onready var cancel := $MarginContainer/VBoxContainer/HBoxContainer/CancelContainer/Cancel
onready var progressbar := $MarginContainer/VBoxContainer/ProgressBar
onready var confirm := $MarginContainer/VBoxContainer/HBoxContainer/ConfirmContainer/Confirm


func _ready():
	if field_path.is_empty() or field_path == null:
		printerr("field_path has not been set on %s" % get_name())

	_field = get_node(field_path)

	connect("popup_hide", Events, "emit_signal", ["overlay_hidden"])
	timer.connect("timeout", self, "_on_Timeout")
	cancel.connect("pressed", self, "_on_Cancel_pressed")
	confirm.connect("pressed", self, "_on_Confirm_pressed")
	get_close_button().hide()


func show() -> void:
	emit_signal("about_to_show")
	confirm.call_deferred("grab_focus")
	_countdown = default_countdown
	progressbar.max_value = default_countdown
	countdown_label.text = String(_countdown)
	progressbar.value = _countdown
	timer.start()
	Events.emit_signal("overlay_displayed")
	Events.call_deferred("emit_signal", "navigation_disabled")
	.show()


func hide() -> void:
	.hide()
	Events.emit_signal("overlay_hidden")
	Events.emit_signal("navigation_enabled")


func _on_Timeout() -> void:
	_countdown -= 1
	countdown_label.text = String(_countdown)
	progressbar.value = _countdown

	if _countdown <= 0:
		_on_Cancel_pressed()
		return
	timer.start()


func _on_Cancel_pressed() -> void:
	_field.revert()
	_field.grab_focus()
	timer.stop()
	hide()


func _on_Confirm_pressed() -> void:
	timer.stop()
	_field.grab_focus()
	_field.save()
	hide()
