# Signal Autoload Pattern
# @see https://www.youtube.com/watch?v=S6PbC4Vqim4
extends Node

############
#### UI ####
############

# config
signal config_file_saved
signal config_file_loade

# field
signal field_description_changed(description)
signal field_focus_entered(field)
signal field_focus_exited(field)
signal focused_row_changed(row)

# gamepad binding
signal gamepad_listening_started
signal gamepad_layout_changed

# keybinding
signal key_listening_started(field, button, scancode)

# navigation
signal navigation_disabled
signal navigation_enabled

# menu
signal menu_route_changed(route)
signal menu_transition_started(anim_name)
signal menu_transition_mid_animated
signal menu_transition_finished

# overlay
signal overlay_displayed
signal overlay_hidden

# save icon
signal save_notification_enabled
