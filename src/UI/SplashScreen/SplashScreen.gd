extends Control

var current_animation_index := 1

onready var animation_player := $AnimationPlayer
onready var animations_list: PoolStringArray = animation_player.get_animation_list()


func _ready():
	if Menu.is_splash_screen_viewed:
		queue_free()
		return
	owner.get_node("TitleScreen").hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_skip_spash_screen"):
		current_animation_index += 1
		if current_animation_index > animations_list.size() - 1:
			set_process_unhandled_input(false)
			finished()
			return
		Events.emit_signal("menu_transition_started", "fade")
		animation_player.play(animations_list[current_animation_index])


func finished() -> void:
	Menu.navigate_to("TitleScreen")
	Menu.current_route = "TitleScreen"
	Menu.is_splash_screen_viewed = true
	queue_free()
