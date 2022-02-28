# Event bus pattern
# @see https://www.youtube.com/watch?v=S6PbC4Vqim4
# @see https://www.gdquest.com/docs/guidelines/best-practices/godot-gdscript/event-bus/
extends Node

############
#### UI ####
############

# config
signal config_file_saved
signal config_file_loaded

# field
signal field_description_changed(description)
signal focused_row_changed(row)

# fieldset
signal fieldset_cleared(fieldset)
signal fieldset_inner_field_navigated(focused_field)

# gamepad binding
signal gamepad_listening_started
signal gamepad_layout_changed
signal gamepad_stick_layout_changed(joy_actions, translation_key)

# keybinding
signal key_listening_started(field, button, scancode)

# locale
signal locale_changed

# menu
signal menu_route_changed(route)
signal menu_transition_started(anim_name)
signal menu_transition_mid_animated
signal menu_transition_finished

# navigation
signal navigation_disabled
signal navigation_enabled

# overlay
signal overlay_displayed
signal overlay_hidden

# Required field unmapped
signal required_field_unmapped_displayed(unmapped_fields)

# save icon
signal save_notification_enabled

# user
signal user_has_changed_gamepad_bindind
