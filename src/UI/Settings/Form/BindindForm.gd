# Manage rebind page
# @category: Form
extends Form
class_name RebindForm


func invalid_callback() -> void:
	Events.emit_signal("navigation_disabled")
	Events.emit_signal("required_field_unmapped_displayed", get_invalid_fields())


func is_invalid() -> bool:
	if not owner.is_current_route:
		return false
	return not get_invalid_fields().empty()


# virtual function
func get_invalid_fields() -> Array:
	return []
