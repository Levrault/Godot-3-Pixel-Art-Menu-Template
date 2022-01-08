# Dropdown field
# Will apply the action when an item is selected
# Will not be added to the Form
#
# Use for important actions like language, resolution, windows mode
tool
class_name DropdownField
extends FieldWithOptions

export var placeholder := "placeholder" setget _set_placeholder

onready var option_button := $OptionButton


func _ready() -> void:
	if Engine.editor_hint:
		return
	yield(owner, "ready")

	connect("focus_entered", self, "_on_Focus_entered")
	option_button.connect("mouse_entered", self, "_on_Mouse_entered")
	option_button.connect("focus_exited", self, "_on_Option_button_focus_exited")
	option_button.connect("item_selected", self, "_on_Item_selected")
	option_button.get_popup().connect("about_to_show", self, "_on_Popup_about_to_show")
	option_button.get_popup().connect("popup_hide", self, "_on_Popup_hide")

	for item in items:
		option_button.add_item(
			item.key if not item.has("translation_key") else tr(item.translation_key)
		)
	revert()


func save() -> void:
	owner.form.has_changed = true
	Config.save_field(owner.form.engine_file_section, key, values.key)


func reset() -> void:
	self.selected_key = EngineSettings.data[owner.form.engine_file_section][key].default
	_compute_index()
	apply()
	option_button.select(_index)


func revert() -> void:
	.revert()
	option_button.select(_index)


func _set_placeholder(value: String) -> void:
	placeholder = value
	$OptionButton.text = placeholder


func _set_selected_key(text: String) -> void:
	selected_key = text
	values = EngineSettings.get_option(owner.form.engine_file_section, key, text)
	option_button.text = text if not values.has("translation_key") else tr(values.translation_key)


func _on_Item_selected(index: int) -> void:
	self.selected_key = items[index]["key"]
	updater.apply(values.properties, true)


func _on_Focus_toggled(is_focused: bool) -> void:
	pass


func _on_Focus_entered() -> void:
	option_button.grab_focus()
	Events.emit_signal("field_focus_entered", self)


func _on_Mouse_entered() -> void:
	Events.emit_signal("field_focus_entered", self)


func _on_Option_button_focus_exited() -> void:
	if not option_button.pressed:
		Events.emit_signal("field_focus_exited", self)


func _on_Popup_about_to_show() -> void:
	Events.emit_signal("navigation_disabled")


func _on_Popup_hide() -> void:
	Events.emit_signal("navigation_enabled")
