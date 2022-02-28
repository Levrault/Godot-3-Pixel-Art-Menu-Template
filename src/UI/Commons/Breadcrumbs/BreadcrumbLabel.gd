# Label that represent a breabcrumbs element
# @category: Breadcrumbs
extends Label

var active := false setget set_active
var translation_key := ""


func _ready() -> void:
	modulate.a = 1.0 if active else .5


func set_active(value: bool) -> void:
	active = value
	modulate.a = 1.0 if active else .3
