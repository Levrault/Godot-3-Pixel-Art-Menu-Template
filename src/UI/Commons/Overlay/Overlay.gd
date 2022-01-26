# A simple overlay
# Show when a dialog is displayed
extends ColorRect


func _ready():
	hide()
	Events.connect("overlay_displayed", self, "show")
	Events.connect("overlay_hidden", self, "hide")
