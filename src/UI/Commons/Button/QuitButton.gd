# Quit application
# @category: Button
extends GenericButton


func _on_Pressed() -> void:
	get_tree().quit()
