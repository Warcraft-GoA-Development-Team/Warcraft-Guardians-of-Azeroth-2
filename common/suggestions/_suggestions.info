# === Structure ===
# Suggestions are pro-active actions that the player is suggested to take.
# Each defined suggestion type can generate zero or more suggestions (same suggestion, but for different targets)
# Only one suggestion is shown for each suggestion type.
#
# Related Defines:
#	NUM_OF_SUGGESTIONS - How many suggestions should show up maximum in the interface
#	GLOBAL_SPAN_MONTHS - How frequently new suggestions should be created
#	PLAYER_SUGGESTION_MONTHS_UPDATE - How frequently existing updates should be checked if they're still valid

suggestion_type_key_name = {				# Key for the current suggestion type. Should be localized

	# The priority for this suggestion type to be shown (compared to other suggestion types)
	# If weight is 0 or less, it is never shown.
	# Scope: player character
	weight = { }

	# Effect that is run when updating/creating possible suggestions. Only interface effects are allowed.
	# To add suggestions of this type, call the `try_create_suggestion = {}` effect within this effect.
	# Scope: player character
	check_create_suggestion = { }
	
	# Effect executed when the player clicks on the suggestion. Only interface effects are allowed.
	# Scope contains all targets saved in `check_create_suggestion` when `try_create_suggestion` was executed,
	# as well as all special actor, recipient etc targets specified in `try_create_suggestion`.
	# Scope root is the player + all saved scoped in `try_create_suggestion`
	effect = { }

	# Score on how "good" a specific suggestion is - it is used to find the best suggestion of this type if there are multiple possible targets
	# If the score is 0 it is never shown.
	# Scope root is the player + all saved scoped in `try_create_suggestion`
	score = { }

	# Check if an suggestion is (still) valid
	# It is immediately checked when `try_create_suggestion` is called, and later at the frequency of PLAYER_SUGGESTION_MONTHS_UPDATE
	# Scope root is the player + all saved scoped in `try_create_suggestion`
	is_valid = { }
}


=== Localization ===

	** For The suggestion type **
key 							-Name. Uses the scope to be localized.
key + "_label"					-Short Label. Uses the scope to be localized.
key + "_desc"					-Description. Uses the scope to be localized.
key + "_click"					-Click info. Uses the scope to be localized.

=== Example ===

test_marry_primary_heir = {
	check_create_suggestion = {
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
			try_create_suggestion = {
				suggestion_type = test_marry_primary_heir
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
