# Data carousel that use to be save inside config.cfg (@see Autoload/Config.gd)
# Will get options and default value from EngineSettings.gd and display them in order
# Will send the new data to the Form node
tool
class_name HListField, "res://assets/icons/field.svg"
extends SliderField

export var infinite_loop := true
onready var _tween := $Tween
onready var previous := $Previous
onready var next := $Next


func _ready() -> void:
	yield(owner, "ready")
	previous.connect("pressed", self, "_on_Previous_value")
	next.connect("pressed", self, "_on_Next_value")


# TODO: Change to tweak file value
func play_arrow_animation(arrow: ToolButton, to: Vector2) -> void:
	_tween.interpolate_property(
		arrow, "rect_position", arrow.rect_position, to, .1, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	_tween.start()


func _on_Previous_value() -> void:
	self.is_pristine = false
	next.modulate.a = 1.0
	_index -= 1

	if _index < 0:
		if infinite_loop:
			_index = items.size() - 1
		else:
			_index = 0
			previous.modulate.a = 0.1

	self.selected_key = items[_index]["key"]

	if _tween.is_active():
		return

	_tween.connect("tween_all_completed", self, "_on_Left_tween_completed")
	play_arrow_animation(previous, Vector2(previous.rect_position.x + 5, previous.rect_position.y))


func _on_Next_value() -> void:
	self.is_pristine = false
	previous.modulate.a = 1.0
	_index += 1

	if _index >= items.size():
		if infinite_loop:
			_index = 0
		else:
			_index = items.size() - 1
			next.modulate.a = 0.1

	self.selected_key = items[_index]["key"]

	if _tween.is_active():
		return

	_tween.connect("tween_all_completed", self, "_on_Right_tween_completed")
	play_arrow_animation(next, Vector2(next.rect_position.x + 5, next.rect_position.y))


func _on_Right_tween_completed() -> void:
	_tween.disconnect("tween_all_completed", self, "_on_Right_tween_completed")
	play_arrow_animation(next, Vector2(next.rect_position.x - 5, next.rect_position.y))


func _on_Left_tween_completed() -> void:
	_tween.disconnect("tween_all_completed", self, "_on_Left_tween_completed")
	play_arrow_animation(previous, Vector2(previous.rect_position.x - 5, previous.rect_position.y))
