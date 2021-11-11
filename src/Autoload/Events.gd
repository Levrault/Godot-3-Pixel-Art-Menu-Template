# Signal Autoload Pattern
# @see https://www.youtube.com/watch?v=S6PbC4Vqim4
extends Node

############
#### UI ####
############

# config
signal config_file_saved
signal config_file_loade

# keybinding
signal key_listening_started(field, button, scancode)
signal key_listening_ended(node)
signal key_listening_cancelled

# notification
signal notification_started(text, size)

# navigation
signal navigation_disabled
signal navigation_enabled

# field
signal field_focus_entered(field)
signal field_focus_exited(field)
signal focused_row_changed(row)

# menu
signal menu_route_changed(route)

# transitions
signal transition_started(anim_name)
signal transition_mid_animated
signal transition_finished
