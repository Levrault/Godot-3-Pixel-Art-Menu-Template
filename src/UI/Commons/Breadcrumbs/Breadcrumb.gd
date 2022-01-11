extends HBoxContainer

const BREADCRUMB_LABEL_SCENE = preload("res://src/UI/Commons/Breadcrumbs/BreadcrumbLabel.tscn")
export (Array, String) var breadcrumbs = []
onready var breadcrumb_root = $BreachcrumbRoot


func _ready() -> void:
	var root = breadcrumbs.pop_front()
	if root == null:
		breadcrumb_root.text = ""
		return

	breadcrumb_root.text = tr(root).capitalize()
	for element in breadcrumbs:
		var new_label = BREADCRUMB_LABEL_SCENE.instance()
		add_child(new_label)
		new_label.text = tr(element).capitalize()

	get_child(get_child_count() - 1).active = true
