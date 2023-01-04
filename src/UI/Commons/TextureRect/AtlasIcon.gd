extends TextureRect
class_name AtlasIcon

enum Icon { DEFAULT, ALT }

const DURATION := 1.0

export var action := ""

var icon_texture: AtlasTexture = null
var alt_icon_texture: AtlasTexture = null
var next_icon: int = Icon.ALT

onready var anim := $AnimationPlayer
onready var label := $Label
onready var timer := $Timer


func _ready() -> void:
	InputManager.connect("device_changed", self, "_on_Device_changed")
	Events.connect("gamepad_layout_changed", self, "_on_Gamepad_layout_changed")
	timer.connect("timeout", self, "_on_Timeout")
	_on_Device_changed(InputManager.device, 0)
	timer.start()


func anim_pulse() -> void:
	anim.play("pulse")


func toggle_icon(icon: int) -> void:
	if icon == Icon.ALT:
		next_icon = Icon.DEFAULT
		texture = alt_icon_texture
		return
	next_icon = Icon.ALT
	texture = icon_texture


func _on_Device_changed(device: String, device_index: int) -> void:
	var joy_string := InputManager.get_device_button_from_action(action, device)
	icon_texture = InputManager.get_device_icon_texture_from_action(joy_string, device)
	alt_icon_texture = InputManager.get_device_icon_texture_from_action(joy_string, device, true)

	if icon_texture == null:
		icon_texture = InputManager.get_device_icon_texture_fallback(device)
		label.text = joy_string
		label.show()

	if alt_icon_texture == null:
		timer.stop()
		if timer.is_connected("timeout", self, "_on_Timeout"):
			timer.disconnect("timeout", self, "_on_Timeout")
	elif not timer.is_connected("timeout", self, "_on_Timeout"):
		timer.stop()
		timer.start()
		timer.connect("timeout", self, "_on_Timeout")

	texture = icon_texture
	next_icon = Icon.ALT


func _on_Gamepad_layout_changed() -> void:
	_on_Device_changed(InputManager.device, 0)


func _on_Timeout() -> void:
	toggle_icon(next_icon)
