# Filter option element of a FieldWithOptions type node 
# @category: Filter
class_name Filter
extends Node


func _ready() -> void:
	yield(owner, "ready")
	yield(get_tree(), "idle_frame")

	if not get_parent() is FieldWithOptions:
		printerr("Parent %s of %s has no options to filter" % [get_parent().get_name(), get_name()])
		return


# virtual function
# apply filter
func apply(options: Array) -> Array:
	return options
