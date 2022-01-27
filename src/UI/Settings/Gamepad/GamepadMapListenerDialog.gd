# Listen and manage a binding with a Gamepad
# @category: Gamepad, Dialog, Rebind
extends WindowDialog

const ALLOWED_AXIS_EVENT := [6, 7]
enum Step { new, remap, conflict, unbind }

var _field: GamepadMapField = null
var _conflicted_field: GamepadMapField = null
var _button: Button = null
var _current_event_identifier := -1
var _new_event_identifier := -1
var _new_event_joy_string := ""

onready var message := $MarginContainer/VBoxContainer/Message
onready var unbind_message := $MarginContainer/VBoxContainer/UnbindMessage
onready var cancel_binding_message := $MarginContainer/VBoxContainer/CancelBindingMessage
onready var buttons_container := $MarginContainer/VBoxContainer/HBoxContainer
onready var cancel_button := $MarginContainer/VBoxContainer/HBoxContainer/CancelContainer/Cancel
onready var rebind_button := $MarginContainer/VBoxContainer/HBoxContainer/RebindContainer/Rebind
onready var timer := $Timer
onready var tick := $Tick
onready var progress_bar := $MarginContainer/VBoxContainer/ProgressBar
onready var debounce_timer := $DebounceTimer


func _ready():
	Events.connect("gamepad_listening_started", self, "_on_Gamepad_listening_started")
	rebind_button.connect("pressed", self, "_on_Apply_pressed")
	cancel_button.connect("pressed", self, "_on_Cancel_pressed")
	timer.connect("timeout", self, "_on_Timer_timeout")
	debounce_timer.connect("timeout", self, "_on_Timeout")
	tick.connect("timeout", self, "_on_Tick_timeout")

	tick.wait_time = timer.wait_time / progress_bar.max_value

	get_close_button().hide()
	buttons_container.hide()
	cancel_button.disabled = true
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel_binding"):
		cancel_binding()
		return

	if event.is_action_pressed("ui_unbind"):
		if _current_event_identifier == -1:
			return
		timer.start()
		tick.start()
		update_ui_for(Step.unbind)
		return
	if event.is_action_released("ui_unbind") and timer.time_left > 0:
		timer.stop()
		update_ui_for(Step.remap)
		return

	if (
		event is InputEventJoypadMotion
		and event.axis_value > 0.1
		and ALLOWED_AXIS_EVENT.has(event.axis)
	):
		map_gamepad_motion_event(event)
		return

	if event is InputEventJoypadButton and event.is_pressed():
		map_gamepad_button_event(event)
		return


# change ui depending on the context
func update_ui_for(step: int, data := {}):
	var unbind_action_key := InputManager.get_device_button_from_action("ui_unbind", _button.type)
	var cancel_binding_action_key := InputManager.get_device_button_from_action(
		"ui_cancel_binding", InputManager.device
	)

	cancel_binding_message.text = tr("rebind.cancel_binding").format(
		{key = cancel_binding_action_key}
	)

	if step == Step.new:
		window_title = tr("rebind.binding_action").format({action = _field.action})
		cancel_binding_message.show()
		message.hide()
		unbind_message.hide()
		progress_bar.hide()
		buttons_container.hide()
		return

	if step == Step.remap:
		window_title = tr("rebind.binding_action").format({action = _field.action})
		message.text = tr("rebind.binding_key").format({key = _button.assigned_to})
		unbind_message.text = tr("rebind.hold_to_unbind").format(
			{
				unbind_action_key = unbind_action_key,
				key = _button.assigned_to,
				action = _field.action
			}
		)
		message.show()
		buttons_container.hide()
		cancel_binding_message.show()
		unbind_message.show()
		progress_bar.hide()
		return

	if step == Step.conflict:
		set_process_input(false)
		window_title = tr("rebind.change_binding")
		message.text = tr("rebind.change_binding_to_new_action").format(
			{new_action = _field.action, key = data.key, previous_action = _conflicted_field.action}
		)
		cancel_binding_message.hide()
		message.show()
		unbind_message.hide()
		buttons_container.show()
		progress_bar.hide()
		debounce_timer.start()
		return

	if step == Step.unbind:
		message.text = tr("rebind.unbinding_action").format(
			{key = _button.assigned_to, action = _field.action}
		)
		unbind_message.text = tr("rebind.cancel_unbind").format(
			{unbind_action_key = unbind_action_key}
		)
		cancel_binding_message.hide()
		progress_bar.value = 0
		progress_bar.show()
		return


func map_gamepad_motion_event(event) -> void:
	_new_event_identifier = event.axis

	if _new_event_identifier == _current_event_identifier:
		cancel_binding()
		return

	_new_event_joy_string = Input.get_joy_axis_string(_new_event_identifier)
	_conflicted_field = owner.form.get_mapped_gamepad_or_null(_new_event_joy_string)
	if _conflicted_field == null:
		map_action()
		return
	if _conflicted_field == _field:
		cancel_binding()
		return

	update_ui_for(
		Step.conflict,
		{
			key = EngineSettings.get_gamepad_button_from_joy_string(
				_new_event_identifier, _new_event_joy_string, _button.type
			)
		}
	)


func map_gamepad_button_event(event) -> void:
	_new_event_identifier = event.button_index

	if _new_event_identifier == _current_event_identifier:
		cancel_binding()
		return

	_new_event_joy_string = Input.get_joy_button_string(_new_event_identifier)
	_conflicted_field = owner.form.get_mapped_gamepad_or_null(_new_event_joy_string)
	if _conflicted_field == null:
		map_action()
		return
	if _conflicted_field == _field:
		cancel_binding()
		return

	update_ui_for(
		Step.conflict,
		{
			key = EngineSettings.get_gamepad_button_from_joy_string(
				_new_event_identifier, _new_event_joy_string, _button.type
			)
		}
	)


func map_action() -> void:
	_button.assign_with_constant(
		EngineSettings.get_gamepad_button_from_joy_string(
			_new_event_identifier, _new_event_joy_string, _button.type
		)
	)
	_field.emit_signal("field_item_selected", _new_event_joy_string)
	owner.form.save()
	close()


func cancel_binding() -> void:
	emit_signal("popup_hide")
	close()


# need to wait the idle_frame when closing
# if not, the grab_focus can fail
func close() -> void:
	hide()
	owner.form.set_process_input(true)
	timer.stop()
	yield(get_tree(), "idle_frame")
	_button.call_deferred("grab_focus")
	_button = null
	_field = null
	_conflicted_field = null
	_current_event_identifier = -1
	_new_event_identifier = -1
	buttons_container.hide()
	set_process_input(false)
	Events.call_deferred("emit_signal", "navigation_enabled")
	Events.emit_signal("overlay_hidden")


func _on_Gamepad_listening_started(field: GamepadMapField, button: Button, current_scancode: int) -> void:
	emit_signal("about_to_show")
	owner.form.set_process_input(false)

	_field = field
	_button = button
	_current_event_identifier = current_scancode

	if _current_event_identifier == -1:
		update_ui_for(Step.new)
	else:
		update_ui_for(Step.remap)

	Events.emit_signal("navigation_disabled")
	Events.emit_signal("overlay_displayed")
	show()
	set_process_input(true)


func _on_Apply_pressed() -> void:
	_conflicted_field.unmap(_new_event_identifier)
	owner.form.save()
	map_action()


func _on_Cancel_pressed() -> void:
	_new_event_identifier = -1
	_conflicted_field = null
	update_ui_for(Step.remap)

	if _current_event_identifier == -1:
		update_ui_for(Step.new)
	else:
		update_ui_for(Step.remap)

	cancel_button.set_deferred("disabled", true)
	set_process_input(true)


func _on_Timer_timeout() -> void:
	set_process_input(false)
	_field.unmap(_current_event_identifier)
	owner.form.save()
	close()


func _on_Tick_timeout() -> void:
	progress_bar.value = progress_bar.value + 1


func _on_Timeout() -> void:
	cancel_button.set_deferred("disabled", false)
	rebind_button.call_deferred("grab_focus")
