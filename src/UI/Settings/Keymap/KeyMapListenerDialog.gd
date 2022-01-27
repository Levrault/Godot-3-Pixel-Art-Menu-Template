# Listen and manage a binding with a keyboard and mouse
# @category: Keyboard, Dialog, Rebind
extends WindowDialog

enum Step { new, remap, conflict, unbind }

var _field: KeyMapField = null
var _conflicted_field: KeyMapField = null
var _button: Button = null
var _current_event_identifier := -1
var _new_event_identifier := -1

onready var message := $MarginContainer/VBoxContainer/Message
onready var unbind_message := $MarginContainer/VBoxContainer/UnbindMessage
onready var cancel_binding_message := $MarginContainer/VBoxContainer/CancelBindingMessage
onready var buttons_container := $MarginContainer/VBoxContainer/HBoxContainer
onready var cancel_button := $MarginContainer/VBoxContainer/HBoxContainer/CancelContainer/Cancel
onready var rebind_button := $MarginContainer/VBoxContainer/HBoxContainer/RebindContainer/Rebind
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
	cancel_binding_message.text = tr("rebind.cancel_binding").format(
		{key = OS.get_scancode_string(InputMap.get_action_list("ui_cancel")[0].scancode)}
	)
	get_close_button().hide()
	buttons_container.hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
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

	if event is InputEventMouseButton:
		map_mouse_event(event)
		return

	if event is InputEventKey and event.pressed and not event.echo:
		map_keyboard_event(event)
		return


# change ui depending on the context
func update_ui_for(step: int, data := {}):
	var unbind_action_key := InputManager.get_device_button_from_action(
		"ui_unbind", InputManager.device
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
		var key := OS.get_scancode_string(_current_event_identifier)
		var default_key := OS.get_scancode_string(_field.values.default)
		if not EngineSettings.keylist["keyboard"].has(
			EngineSettings.get_keyboard_or_mouse_key_from_scancode(_current_event_identifier)
		):
			key = tr(EngineSettings.get_mouse_button_string(_button.assigned_to))
		if not EngineSettings.keylist["keyboard"].has(
			EngineSettings.get_keyboard_or_mouse_key_from_scancode(_field.values.default)
		):
			default_key = tr(EngineSettings.get_mouse_button_string(_button.assigned_to))

		window_title = tr("rebind.binding_action").format({action = _field.action})
		message.text = tr("rebind.binding_key_with_default").format(
			{key = key, default_key = default_key}
		)
		unbind_message.text = tr("rebind.hold_to_unbind").format(
			{
				unbind_action_key = unbind_action_key,
				key = OS.get_scancode_string(_current_event_identifier),
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
		message.show()
		unbind_message.hide()
		buttons_container.show()
		rebind_button.call_deferred("grab_focus")
		progress_bar.hide()
		return

	if step == Step.unbind:
		message.text = tr("rebind.unbinding_action").format(
			{key = OS.get_scancode_string(_current_event_identifier), action = _field.action}
		)
		unbind_message.text = tr("rebind.cancel_unbind").format(
			{unbind_action_key = unbind_action_key}
		)
		cancel_binding_message.hide()
		progress_bar.value = 0
		progress_bar.show()
		return


func map_mouse_event(event: InputEventMouseButton) -> void:
	_new_event_identifier = event.button_index
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
	_new_event_identifier = event.scancode

	if event.is_action_pressed("ui_cancel") or _new_event_identifier == _current_event_identifier:
		cancel_binding()
		return

	_conflicted_field = owner.form.get_mapped_key_or_null(_new_event_identifier)
	if _conflicted_field == null:
		map_action()
		return
	if _conflicted_field == _field:
		cancel_binding()
		return

	update_ui_for(Step.conflict, {key = OS.get_scancode_string(_new_event_identifier)})


func map_action() -> void:
	_button.assign_with_scancode(_new_event_identifier)
	_field.apply_changes(_button.key)
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


func _on_Key_listening_started(field: KeyMapField, button: Button, current_scancode: int) -> void:
	emit_signal("about_to_show")
	owner.form.set_process_input(false)
	Events.emit_signal("navigation_disabled")
	_field = field
	_button = button
	_current_event_identifier = current_scancode

	if _current_event_identifier == -1:
		update_ui_for(Step.new)
	else:
		update_ui_for(Step.remap)

	Events.emit_signal("overlay_displayed")
	show()
	set_process_input(true)


func _on_Apply_pressed() -> void:
	_conflicted_field.unmap(_new_event_identifier)
	_conflicted_field.apply_changes(_button.key)
	map_action()


func _on_Cancel_pressed() -> void:
	_new_event_identifier = -1
	_conflicted_field = null

	if _current_event_identifier == -1:
		update_ui_for(Step.new)
	else:
		update_ui_for(Step.remap)

	set_process_input(true)


func _on_Timer_timeout() -> void:
	set_process_input(false)
	_field.unmap(_current_event_identifier)
	_field.apply_changes(_button.key)
	close()


func _on_Tick_timeout() -> void:
	progress_bar.value = progress_bar.value + 1
