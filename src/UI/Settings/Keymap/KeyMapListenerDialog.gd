extends WindowDialog

enum Step { new, remap, conflict, unbind }
enum Control { mouse, keyboard, gamepad }

var _unbind_action_key := OS.get_scancode_string(InputMap.get_action_list("ui_unbind")[0].scancode)
var _current_control: int = Control.keyboard
var _field: KeyMapField = null
var _conflicted_field: KeyMapField = null
var _button: Button = null
var _current_scancode := -1
var _new_scancode := -1

onready var message := $MarginContainer/VBoxContainer/Message
onready var unbind_message := $MarginContainer/VBoxContainer/UnbindMessage
onready var cancel_binding_message := $MarginContainer/VBoxContainer/CancelBindingMessage
onready var buttons_container := $MarginContainer/VBoxContainer/HBoxContainer
onready var cancel_button := $MarginContainer/VBoxContainer/HBoxContainer/LeftContainer/Cancel
onready var rebind_button := $MarginContainer/VBoxContainer/HBoxContainer/RightContainer/Rebind
onready var timer := $Timer
onready var tick := $Tick
onready var progress_bar := $MarginContainer/VBoxContainer/ProgressBar


func _ready():
	Events.connect("key_listening_started", self, "_on_Key_listening_started")
	rebind_button.connect("pressed", self, "_on_Apply_pressed")
	cancel_button.connect("pressed", self, "_on_Cancel_pressed")
	timer.connect("timeout", self, "_on_Timer_timeout")
	tick.connect("timeout", self, "_on_Tick_timeout")
	tick.wait_time = timer.wait_time / progress_bar.max_value
	get_close_button().hide()
	buttons_container.hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_unbind"):
		timer.start()
		tick.start()
		update_ui_for(Step.unbind)
		return
	if event.is_action_released("ui_unbind"):
		timer.stop()
		update_ui_for(Step.remap)
		return

	if event is InputEventMouseButton:
		map_mouse_event(event)
		return

	if event is InputEventKey and event.pressed and not event.echo:
		map_keyboard_event(event)
		return


func update_ui_for(step: int, data := {}):
	if step == Step.new:
		window_title = tr("ui_controls_binding_action").format({action = _field.action})
		cancel_binding_message.show()
		message.hide()
		unbind_message.hide()
		progress_bar.hide()
		return

	if step == Step.remap:
		var key := OS.get_scancode_string(_current_scancode)
		var default_key := OS.get_scancode_string(_field.values.default)
		print(_field.values.default)
		if not EngineSettings.keylist["keyboard"].has(
			EngineSettings.get_keyboard_or_mouse_key_from_scancode(_current_scancode)
		):
			key = tr(EngineSettings.get_mouse_button_string(_button.assigned_to))
		if not EngineSettings.keylist["keyboard"].has(
			EngineSettings.get_keyboard_or_mouse_key_from_scancode(_field.values.default)
		):
			default_key = tr(EngineSettings.get_mouse_button_string(_button.assigned_to))

		window_title = tr("ui_controls_binding_action").format({action = _field.action})
		message.text = tr("ui_controls_binding_key").format({key = key, default_key = default_key})
		unbind_message.text = tr("ui_controls_hold_to_unbind").format(
			{
				unbind_action_key = _unbind_action_key,
				key = OS.get_scancode_string(_current_scancode),
				action = _field.action
			}
		)
		message.show()
		cancel_binding_message.show()
		unbind_message.show()
		progress_bar.hide()
		return

	if step == Step.conflict:
		set_process_input(false)
		window_title = tr("ui_controls_change_binding")
		message.text = tr("ui_controls_change_binding_to_new_action").format(
			{new_action = _field.action, key = data.key, previous_action = _conflicted_field.action}
		)
		unbind_message.hide()
		buttons_container.show()
		rebind_button.call_deferred("grab_focus")
		progress_bar.hide()
		return

	if step == Step.unbind:
		message.text = tr("ui_controls_unbinding_action").format(
			{key = OS.get_scancode_string(_current_scancode), action = _field.action}
		)
		unbind_message.text = tr("ui_controls_cancel_unbind").format(
			{unbind_action_key = _unbind_action_key}
		)
		cancel_binding_message.hide()
		progress_bar.value = 0
		progress_bar.show()
		return


func map_mouse_event(event: InputEventMouseButton) -> void:
	_new_scancode = event.button_index
	_conflicted_field = owner.form.get_mapped_key_or_null(event.button_index)

	if _conflicted_field == null:
		map_action()
		return
	if _conflicted_field == _field:
		cancel_binding()
		return

	set_process_input(false)
	var conflicted_button = _conflicted_field.get_button_by_scancode(event.button_index)
	update_ui_for(
		Step.conflict,
		{key = tr(EngineSettings.get_mouse_button_string(conflicted_button.assigned_to))}
	)


func map_keyboard_event(event: InputEventKey) -> void:
	_new_scancode = event.scancode

	if event.is_action_pressed("ui_cancel") or _new_scancode == _current_scancode:
		cancel_binding()
		return

	_conflicted_field = owner.form.get_mapped_key_or_null(_new_scancode)
	if _conflicted_field == null:
		map_action()
		return
	if _conflicted_field == _field:
		cancel_binding()
		return

	update_ui_for(Step.conflict, {key = OS.get_scancode_string(_new_scancode)})


func map_action() -> void:
	_button.assign_with_scancode(_new_scancode)
	_field.apply_changes(_button.key)
	close()


func cancel_binding() -> void:
	Events.emit_signal("key_listening_cancelled")
	close()


func close() -> void:
	hide()
	timer.stop()
	Events.emit_signal("field_focus_entered", _field)
	_button.call_deferred("grab_focus")
	_button = null
	_field = null
	_conflicted_field = null
	_current_scancode = -1
	_new_scancode = -1
	buttons_container.hide()
	set_process_input(false)
	Events.call_deferred("emit_signal", "navigation_enabled")


func _on_Key_listening_started(field: KeyMapField, button: Button, current_scancode: int) -> void:
	Events.emit_signal("navigation_disabled")
	_field = field
	_button = button
	_current_scancode = current_scancode

	if _current_scancode == -1:
		update_ui_for(Step.new)
	else:
		update_ui_for(Step.remap)
	show()
	set_process_input(true)


func _on_Apply_pressed() -> void:
	_conflicted_field.unmap(_new_scancode)
	_conflicted_field.apply_changes(_button.key)
	map_action()


func _on_Cancel_pressed() -> void:
	_new_scancode = -1
	_conflicted_field = null
	window_title = tr("ui_controls_binding_action").format({action = _field.action})
	message.text = tr("ui_controls_binding_key").format(
		{
			key = OS.get_scancode_string(_current_scancode),
			default_key = OS.get_scancode_string(_field.values.default)
		}
	)
	unbind_message.show()
	buttons_container.hide()
	set_process_input(true)


func _on_Timer_timeout() -> void:
	set_process_input(false)
	_field.unmap(_current_scancode)
	_field.apply_changes(_button.key)
	close()


func _on_Tick_timeout() -> void:
	progress_bar.value = progress_bar.value + 1
