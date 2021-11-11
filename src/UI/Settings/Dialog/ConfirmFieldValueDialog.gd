# Warm user about the new resolution
# Rollback to previous resolution if the user doesn't confirm
extends WindowDialog

export (NodePath) var field_path = ""
export var default_countdown := 15

var _field: Field = null
var _countdown := default_countdown

onready var _timer := $Timer
onready var _countdown_label := $MarginContainer/VBoxContainer/Countdown
onready var _cancel := $MarginContainer/VBoxContainer/HBoxContainer/CancelContainer/Cancel
onready var _progressbar := $MarginContainer/VBoxContainer/ProgressBar
onready var _ok := $MarginContainer/VBoxContainer/HBoxContainer/OkContainer/Ok


func _ready():
	if field_path.is_empty() or field_path == null:
		printerr("field_path has not been set on %s" % get_name())

	_field = get_node(field_path)

	_timer.connect("timeout", self, "_on_Timeout")
	_cancel.connect("pressed", self, "_on_Cancel_pressed")
	_ok.connect("pressed", self, "_on_Ok_pressed")


func show() -> void:
	_ok.call_deferred("grab_focus")
	_countdown = default_countdown
	_progressbar.max_value = default_countdown
	_countdown_label.text = String(_countdown)
	_timer.start()
	.show()


func _on_Timeout() -> void:
	_countdown -= 1
	_countdown_label.text = String(_countdown)
	_progressbar.value = _countdown

	if _countdown <= 0:
		_on_Cancel_pressed()
		return
	_timer.start()


func _on_Cancel_pressed() -> void:
	_field.revert()
	_field.grab_focus()
	_timer.stop()
	hide()


func _on_Ok_pressed() -> void:
	_timer.stop()
	_field.grab_focus()
	_field.save()
	hide()
