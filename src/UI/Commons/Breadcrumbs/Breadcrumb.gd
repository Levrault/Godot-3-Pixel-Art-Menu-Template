# Display a breadcrumbs based on an array of values
# @category: Breadcrumbs
extends HBoxContainer

const BREADCRUMB_LABEL_SCENE = preload("res://src/UI/Commons/Breadcrumbs/BreadcrumbLabel.tscn")

export (Array, String) var breadcrumbs = []

onready var breadcrumb_root = $BreachcrumbRoot


func _ready() -> void:
	Events.connect("locale_changed", self, "translate")
	initialize()


func initialize() -> void:
	var elements :Array = breadcrumbs.duplicate();
	var root = elements.pop_front()
	if root == null:
		breadcrumb_root.text = ""
		return

	breadcrumb_root.text = tr(root).capitalize() + "·"
	for element in breadcrumbs:
		var new_label = BREADCRUMB_LABEL_SCENE.instance()
		add_child(new_label)
		new_label.text = tr(element).capitalize()
		new_label.translation_key = element

	get_child(get_child_count() - 1).active = true


func translate() -> void:
	for child in get_children():
		child.text = tr(child.translation_key)

