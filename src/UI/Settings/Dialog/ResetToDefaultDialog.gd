extends WindowDialog

onready var dialog_text = $MarginContainer/VBoxContainer/Label
onready var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer/RestoreContainer/Restore
onready var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer/CancelContainer/Cancel


func _ready() -> void:
	connect("popup_hide", Events, "emit_signal", ["overlay_hidden"])
	confirm_button.connect("pressed", self, "_on_Confirm_pressed")
	cancel_button.connect("pressed", self, "_on_Cancel_pressed")
	get_close_button().hide()


func show() -> void:
	.show()
	Events.emit_signal("overlay_displayed")
	confirm_button.grab_focus()


func _on_Cancel_pressed() -> void:
	Events.emit_signal("overlay_hidden")
	hide()


func _on_Confirm_pressed() -> void:
	Events.emit_signal("overlay_hidden")
	hide()
