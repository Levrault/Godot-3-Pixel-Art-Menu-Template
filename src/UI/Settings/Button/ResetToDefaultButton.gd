extends Button

onready var confirmation_dialog := $ConfirmationDialog


func _ready():
	connect("pressed", self, "_on_Pressed")
	confirmation_dialog.get_ok().connect("pressed", self, "_on_Confirmation_ok_pressed")


func _on_Pressed() -> void:
	confirmation_dialog.popup()


func _on_Confirmation_ok_pressed() -> void:
	owner.form.reset()
