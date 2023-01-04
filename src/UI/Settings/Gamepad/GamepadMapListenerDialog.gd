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

onready var bound_to_container := $MarginContainer/VBoxContainer/BoundToContainer
onready var bound_to_icon := bound_to_container.get_node("HBoxContainer/Icon")

onready var unbinding_action_container := $MarginContainer/VBoxContainer/UnbingActionContainer
onready var unbinding_action_icon := unbinding_action_container.get_node("HBoxContainer/Icon")
onready var unbinding_action_from_action_label := unbinding_action_container.get_node(
	"HBoxContainer/FromAction"
)

onready var change_binding_to_new_action_container := $MarginContainer/VBoxContainer/ChangeBindingToNewActionContainer
onready var change_binding_to_new_action_icon := change_binding_to_new_action_container.get_node(
	"BindingContainer/HBoxContainer/Icon"
)
onready var change_binding_to_new_action_label := change_binding_to_new_action_container.get_node(
	"LabelContainer/ToNewAction"
)

onready var cancel_binding_container := $MarginContainer/VBoxContainer/CancelBindingContainer
onready var cancel_binding_icon := cancel_binding_container.get_node("HBoxContainer/Icon")

onready var hold_to_unbind_container := $MarginContainer/VBoxContainer/HoldToUnbindContainer
onready var hold_to_icon_unbind := hold_to_unbind_container.get_node("HBoxContainer/IconUnbind")
onready var hold_to_icon_action := hold_to_unbind_container.get_node("HBoxContainer/IconAction")
onready var hold_to_icon_from_action_label := hold_to_unbind_container.get_node(
	"HBoxContainer/FromAction"
)

onready var release_to_cancel_unbind_container := $MarginContainer/VBoxContainer/ReleaseToCancelUnbindContainer
onready var release_to_cancel_unbind_icon := release_to_cancel_unbind_container.get_node(
	"HBoxContainer/Icon"
)

onready var buttons_container := $MarginContainer/VBoxContainer/HBoxContainer
onready var cancel_button := buttons_container.get_node("CancelContainer/Cancel")
onready var rebind_button := buttons_container.get_node("RebindContainer/Rebind")

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
	# set icone
	var ui_unbind_texture = InputManager.get_device_icon_texture_from_action(
		InputManager.get_device_button_from_action("ui_unbind", _button.type), _button.type
	)
	hold_to_icon_unbind.texture = ui_unbind_texture
	hold_to_icon_from_action_label.text = tr("rebind.from_action").format({action = _field.action})
	release_to_cancel_unbind_icon.texture = ui_unbind_texture

	cancel_binding_icon.texture = InputManager.get_device_icon_texture_from_action(
		InputManager.get_device_button_from_action("ui_cancel_binding", _button.type), _button.type
	)

	if step == Step.new:
		window_title = tr("rebind.binding_action").format({action = _field.action})
		bound_to_container.hide()
		unbinding_action_container.hide()
		change_binding_to_new_action_container.hide()
		progress_bar.hide()
		cancel_binding_container.show()
		hold_to_unbind_container.hide()
		release_to_cancel_unbind_container.hide()
		buttons_container.hide()
		return

	if step == Step.remap:
		window_title = tr("rebind.binding_action").format({action = _field.action})
		bound_to_icon.texture = InputManager.get_device_icon_texture_from_action(
			_button.assigned_to, _button.type
		)
		bound_to_container.show()
		unbinding_action_container.hide()
		change_binding_to_new_action_container.hide()
		progress_bar.hide()
		cancel_binding_container.show()
		hold_to_unbind_container.show()
		release_to_cancel_unbind_container.hide()
		buttons_container.hide()
		return

	if step == Step.conflict:
		set_process_input(false)
		window_title = tr("rebind.change_binding")
		change_binding_to_new_action_label.text = tr("rebind.to_new_action").format(
			{new_action = _field.action, previous_action = _conflicted_field.action}
		)
		change_binding_to_new_action_icon.texture = InputManager.get_device_icon_texture_from_action(
			_conflicted_field.default_button.assigned_to, _button.type
		)
		bound_to_container.hide()
		unbinding_action_container.hide()
		change_binding_to_new_action_container.show()
		progress_bar.hide()
		cancel_binding_container.hide()
		hold_to_unbind_container.hide()
		release_to_cancel_unbind_container.hide()
		buttons_container.show()
		debounce_timer.start()
		return

	if step == Step.unbind:
		unbinding_action_icon.texture = InputManager.get_device_icon_texture_from_action(
			_button.assigned_to, _button.type
		)
		unbinding_action_from_action_label.text = tr("rebind.from_action").format(
			{action = _field.action}
		)
		bound_to_container.hide()
		unbinding_action_container.show()
		change_binding_to_new_action_container.hide()
		progress_bar.hide()
		cancel_binding_container.hide()
		hold_to_unbind_container.hide()
		release_to_cancel_unbind_container.show()
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
	#yield(get_tree(), "idle_frame")
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
