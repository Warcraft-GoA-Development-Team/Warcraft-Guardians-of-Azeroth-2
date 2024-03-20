=== Structure ===

action_key_name = {				# Key for the current action. Should be localized
	type =	action				# Default behavior, shows up in the dropdown list of "current situation"
			alert					# Show a separate icon for each important action
			tutorial				# An action that will trigger a tutorial lesson. These actions are the only ones that will show up while is_gamestate_tutorial_active = yes
	icon = blah					# Use a specific icon name rather than action_key_name
	is_dangerous = yes/no		# Should this action be treated as an dangerous one? For UI purposes only. Default: no
	priority = (number) 		#Static number, the higher it is the higher it will appear in the list. Default is -1. Need to restart the game for it to take effect. is_dangerous will always appear higher
	combine_into_one = yes/no	# If this action can have multiple instances (with different scopes), should they be combined into one entry that can be expanded? Default: no

	# Effect that checks if the action can be shown. Only interface effects are allowed. Should probably run try_create_important_action.
	# Scope: player character
	check_create_action = { }
	
	# Effect excutes when the player clicks on the action. Only interface effects are allowed
	# Scope contains all targets saved in check_create_action when try_create_important_action was executed,
	# as well as all special actor, recipient etc targets specified in try_create_important_action.
	# Scope root is the player.
	effect = { }
	
	soundeffect = ...			# An audio event that will be played when this important action is added to the screen. If not specified, falls back to the NAudio::NGameAudioEffects::DEFAULT_IMPORTANT_ACTION define

	
}


=== Localization ===

	** For The action type **
key 							-Name. Uses the scope to be localized.
key + "_label"					-Short Label. Uses the scope to be localized.
key + "_desc"					-Description. Uses the scope to be localized.
key + "_click"					-Click info. Uses the scope to be localized.
key + "_combined_label"			-Label used if it's combined

	** For The action gui item **
key + "_combined_group_label"		-Label of the combined group. Includes the number of items as $NUM$
key + "_combined_group_name"		-Name of the combined group. For tooltip.
key + "_combined_group_description"	-Name of the combined group. For tooltip.


=== Example ===

test_marry_primary_heir = {
	type = alert

	check_create_action = {
		if = {
			limit = {
				AND = {
					target_is_valid_character = primary_heir
					primary_heir = {
						is_married = no
						is_adult = yes
					}
				}
			}
			try_create_important_action = {
				important_action_type = test_marry_primary_heir
				recipient = primary_heir
			}
		}
	}

	effect = {
		scope:recipient = {
			open_view_data = {
				view = character
			}
		}
		#open_interaction_window = {
		#	interaction = arrange_marriage
		#	actor = root
		#	recipient =  scope:recipient
		#}
	}
}
