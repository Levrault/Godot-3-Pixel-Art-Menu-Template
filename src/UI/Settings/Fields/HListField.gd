# Data carousel that use to be save inside config.cfg (@see Autoload/Config.gd)
# Will get options and default value from EngineSettings.gd and display them in order
# Will send the new data to the Form node
tool
class_name HListField
extends FieldWithOptions

export var infinite_loop := true
export var placeholder := "placeholder" setget _set_placeholder

onready var _tween := $Tween
onready var previous := $Previous
onready var next := $Next


func _ready() -> void:
	if Engine.editor_hint:
		return
	yield(owner, "ready")

	initialize()
	connect("focus_entered", self, "emit_signal", ["field_focus_entered"])
	connect("focus_exited", self, "emit_signal", ["field_focus_exited"])
	previous.connect("pressed", self, "_on_Previous_value")
	next.connect("pressed", self, "_on_Next_value")


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
	emit_signal("field_item_selected", selected_key)


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
	emit_signal("field_item_selected", selected_key)


func _on_Right_tween_completed() -> void:
	_tween.disconnect("tween_all_completed", self, "_on_Right_tween_completed")
	play_arrow_animation(next, Vector2(next.rect_position.x - 5, next.rect_position.y))


func _on_Left_tween_completed() -> void:
	_tween.disconnect("tween_all_completed", self, "_on_Left_tween_completed")
	play_arrow_animation(previous, Vector2(previous.rect_position.x - 5, previous.rect_position.y))
