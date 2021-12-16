extends Button

onready var confirmation_dialog := $ConfirmationDialog


func _ready():
	connect("pressed", self, "_on_Pressed")
	confirmation_dialog.get_close_button().hide()
	confirmation_dialog.connect("popup_hide", Events, "emit_signal", ["overlay_hidden"])
	confirmation_dialog.get_ok().connect("pressed", self, "_on_Confirmation_ok_pressed")


func _on_Pressed() -> void:
	Events.emit_signal("overlay_displayed")
	confirmation_dialog.popup()


func _on_Confirmation_ok_pressed() -> void:
	Events.emit_signal("overlay_hidden")
	owner.form.reset()
