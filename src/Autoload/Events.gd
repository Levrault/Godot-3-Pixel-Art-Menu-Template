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
signal keybinding_started(scancode)
signal keybinding_canceled
signal keybinding_resetted
signal keybinding_key_selected(scancode)

# notification
signal notification_started(text, size)

# navigation
signal navigation_disabled
signal navigation_enabled

# menu
signal menu_route_changed(route)

# transitions
signal transition_started(anim_name)
signal transition_mid_animated
signal transition_finished
