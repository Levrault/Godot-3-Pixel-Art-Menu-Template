# Dropdown field
# Use for important actions like language, resolution, windows mode
# Should be use for action that can have a direct and instant impact on the visual
#
# e.g. engine.cfg
# ```
# window_mode = {
#     "default": "borderless",
#     "options": [ {
#         "key": "fullscreen",
#         "translation_key": "cfg.fullscreen",
#         "properties": {
#             "display/window/size/fullscreen": true,
#             "display/window/size/borderless": false,
#         }
#     }, {
#         "key": "borderless",
#         "translation_key": "cfg.borderless",
#         "properties": {
#             "display/window/size/fullscreen": false,
#             "display/window/size/borderless": true,
#         }
#     }, {
#         "key": "windowed",
#         "translation_key": "cfg.windowed",
#         "properties": {
#             "display/window/size/fullscreen": false,
#             "display/window/size/borderless": false,
#         }
#     } ]
# }
# ```
# @category: Field
tool
class_name DropdownField
extends FieldWithOptions

signal field_item_focused(index)
signal field_popup_opened
signal field_popup_closed

export var placeholder := "placeholder" setget _set_placeholder

onready var option_button := $OptionButton


func _ready() -> void:
	if Engine.editor_hint:
		return
	yield(owner, "ready")

	Events.connect("locale_changed", self, "translate")
	connect("focus_entered", self, "_on_Focus_entered")
	option_button.connect("focus_exited", self, "_on_Option_button_focus_exited")
	option_button.connect("item_selected", self, "_on_Item_selected")
	option_button.connect("item_focused", self, "_on_Item_focused")
	option_button.get_popup().connect("about_to_show", self, "_on_Popup_about_to_show")
	option_button.get_popup().connect("popup_hide", self, "_on_Popup_hide")

	var index := 0
	for item in items:
		option_button.add_item(
			item.key if not item.has("translation_key") else tr(item.translation_key)
		)
		option_button.set_item_metadata(index, {
			"translation_key": item.key if not item.has("translation_key") else item.translation_key
		})
		index += 1

	initialize()


# Check if the field has the correct data to be created
# if not, reset to engine`s default value
# if the data are corrects, load last saved data
func initialize() -> void:
	.initialize()
	call_deferred("revert")


func save() -> void:
	owner.form.has_changed = true
	Config.save_field(owner.form.engine_file_section, key, values.key)


# Change to Engine`s default value (engine.cfg)
func reset() -> void:
	self.selected_key = EngineSettings.data[owner.form.engine_file_section][key].default
	_compute_index()
	apply()
	option_button.select(_index)


# Change to user config value
# Used to load the last saved data
func revert() -> void:
	.revert()
	option_button.select(_index)


func translate() -> void:
	for i in option_button.get_item_count():
		option_button.set_item_text(i, tr(option_button.get_item_metadata(i).translation_key))
	option_button.text = selected_key if not values.has("translation_key") else tr(values.translation_key)


func _set_placeholder(value: String) -> void:
	placeholder = value
	$OptionButton.text = placeholder


func _set_selected_key(text: String) -> void:
	selected_key = text
	values = EngineSettings.get_option(owner.form.engine_file_section, key, text)
	option_button.text = text if not values.has("translation_key") else tr(values.translation_key)


func _on_Item_selected(index: int) -> void:
	self.selected_key = items[index]["key"]
	emit_signal("field_item_selected", selected_key)
	updater.apply(values.properties, true)


func _on_Focus_entered() -> void:
	option_button.grab_focus()
	emit_signal("field_focus_entered")


func _on_Option_button_focus_exited() -> void:
	if not option_button.pressed:
		emit_signal("field_focus_exited")


func _on_Popup_about_to_show() -> void:
	Events.emit_signal("navigation_disabled")
	emit_signal("field_popup_opened")


func _on_Popup_hide() -> void:
	Events.emit_signal("navigation_enabled")
	emit_signal("field_popup_closed")


func _on_Item_focused(index: int) -> void:
	emit_signal("field_item_focused", index)
