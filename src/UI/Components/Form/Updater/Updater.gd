class_name Updater
extends Node


func _ready() -> void:
	yield(owner, "ready")
	yield(get_tree(), "idle_frame")
	apply(get_parent().values.properties)


func apply(properties: Dictionary, show_dialog := true) -> void:
	pass
