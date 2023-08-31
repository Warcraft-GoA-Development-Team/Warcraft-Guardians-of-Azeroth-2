Structure:

# Travel Option
key = {
	# Trigger which has to be true to be shown while planning travel. Scope is the travel owner.
	is_shown = {}

	# Trigger which has to be true to be able to be picked while planning travel. Scope is the travel owner.
	is_valid = {}

	# Scripted cost which will be applied to the travel owner once the travel start, if the option is picked. Scope is the travel owner character.
	# We have chosen to remove the gold cost and have the player choose what options they want to apply for a limited number of slots. Still maintaining it for special options.
	cost = {}

	# Travel modifier which gets applied to the travels safety/speed if the option is picked.
	travel_modifier = {
		travel_speed = number
		travel_safety = number
	}

	# Character modifier that gets applied to the travel owner character
	owner_modifier = {}

	# Effect that gets triggered once the travel starts, or once the option is gained mid-travel.
	# Root - Travel Owner.
	# scope:travel_speed - Travel Speed (percentage points above 100%)
	# scope:travel_safety - Travel Safety
	on_applied_effect = {}

	# Effect that gets triggered once the travel ends.
	# Root - Travel Owner.
	# scope:travel_speed - Travel Speed (percentage points above 100%)
	# scope:travel_safety - Travel Safety
	on_travel_end_effect = {}

	### Brief: ai_will_do (scripted value int32)
	# How likely is the AI to pick this option if valid? Options will be selected using weighted random.
	# Options will be re-evaluated after each option is added.
	#
	# Root - Travel Plan.
	# Extra scopes:
	#   scope:highest_future_danger_value - highest danger value on route; to compare with `travel_safety`
	ai_will_do = {}

	# Select which court characters are added to the travel entourage when this option is added.
	# Weighted list is evaluated until all values are negative, or `max` is reached.
	travel_entourage_selection = {
		# List is all court characters.
		# root = character in the travel plan owners' court
		# scope:owner = character owning the travel plan
		weight = {
			value = 10
		}

		# Up to how many characters to select for a player
		max = 2
		
		# Up to how many characters to select for an AI
		ai_max = 2
	}
}
