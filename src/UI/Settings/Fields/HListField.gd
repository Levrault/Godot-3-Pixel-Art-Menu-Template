# Carousel for non direct action
# Navigation can be made with ui_left and ui_right
#
# e.g. engine.cfg
# ```
# gamepad_stick_layout = {
#     "default": "movement/camera",
#     "options": [ {
#         "key": "movement/camera",
#         "translation_key": "cfg.stick_layout_movement_camera",
#         "properties": {
#             "y_axis": true
#         }
#     }, {
#         "key": "camera/movement",
#         "translation_key": "cfg.stick_layout_camera_movement",
#         "properties": {
#             "y_axis": false
#         }
#     } ]
# }
# ```
# @category: Field
tool
class_name HListField
extends FieldWithOptions

export var infinite_loop := true
export var placeholder := "placeholder" setget _set_placeholder

onready var _tween := $Tween
onready var previous := $Previous
onready var next := $Next
onready var label := $Value


func _ready() -> void:
	if Engine.editor_hint:
		return
	yield(owner, "ready")

	initialize()
	Events.connect("locale_changed", self, "translate")
	connect("focus_entered", self, "emit_signal", ["field_focus_entered"])
	connect("focus_exited", self, "emit_signal", ["field_focus_exited"])
	previous.connect("pressed", self, "_on_Previous_value")
	next.connect("pressed", self, "_on_Next_value")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		if event.get_action_strength("ui_left") == 1:
			_on_Previous_value()
			return
		if event.get_action_strength("ui_right") == 1:
			_on_Next_value()
			return
		return

	if event.is_action_pressed("ui_left"):
		_on_Previous_value()
		return

	if event.is_action_pressed("ui_right"):
		_on_Next_value()
		return


# Check if the field has the correct data to be created
# if not, reset to engine`s default value
# if the data are corrects, load last saved data
func initialize() -> void:
	.initialize()
	revert()


func translate() -> void:
	label.text = selected_key if not values.has("translation_key") else tr(values.translation_key)


func _set_placeholder(value: String) -> void:
	placeholder = value
	$Value.text = placeholder


func _set_selected_key(text: String) -> void:
	._set_selected_key(text)
	translate()


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
