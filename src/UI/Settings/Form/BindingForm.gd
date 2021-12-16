extends Form
class_name BindingForm


func invalid_callback() -> void:
	Events.emit_signal("navigation_disabled")
	$RequiredFieldUnmapped.set_message(get_invalid_fields())
	$RequiredFieldUnmapped.show()


func is_invalid() -> bool:
	if not owner.is_current_route:
		return false
	return not get_invalid_fields().empty()


# abstract to override
func get_invalid_fields() -> Array:
	return []
