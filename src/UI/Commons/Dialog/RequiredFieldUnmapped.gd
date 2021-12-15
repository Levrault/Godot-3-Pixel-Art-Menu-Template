extends WindowDialog


onready var ok_btn := $MarginContainer/VBoxContainer/HBoxContainer/Ok

func _ready() -> void:
	ok_btn.connect("pressed", self, "hide")


func set_message(unmapped_fields := []) -> void:
	var actions := ""
	var separator := ", "
	for field in unmapped_fields:
		actions += field.action + separator 
	actions = actions.left(actions.length() - separator.length())

	$MarginContainer/VBoxContainer/Message.text = tr("ui_required_action_unmapped").format({ actions = actions })


func show() -> void:
	visible = true
	ok_btn.call_deferred("grab_focus")
