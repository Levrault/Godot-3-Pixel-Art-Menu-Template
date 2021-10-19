tool
class_name SliderField, "res://assets/icons/field.svg"
extends Field


func _ready() -> void:
	yield(owner, "ready")
	.revert()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_on_Previous_value()
		return

	if event.is_action_pressed("ui_right"):
		_on_Next_value()
		return


func _set_placeholder(value: String) -> void:
	placeholder = value
	$Value.text = placeholder


func _set_selected_key(text: String) -> void:
	._set_selected_key(text)
	$Value.text = text if not values.has("translation_key") else tr(values.translation_key)


func _on_Previous_value() -> void:
	self.is_pristine = false


func _on_Next_value() -> void:
	self.is_pristine = false
