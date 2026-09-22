### Situation History

date = {
	effect = {
		...
	}
}

# Examples:
# Start The Great Steppe Situation at the very beginning of the game 1.1.1
1.1.1 = {
	effect = {
		if = {
			limit = { has_mpo_dlc_trigger = yes }
			start_situation = {
				type = the_great_steppe
				start_phase = situation_steppe_abundant_grazing_season
			}
		}
	}
}

# End iberian_struggle struggle in 716.1.1. If the struggle didn't start before then there is going to be an error (be sure to run an existence check)
716.1.1 = {
	effect = {
		if = {
			limit = { has_mpo_dlc_trigger = yes }
			situation:the_great_steppe = { end_situation = yes }
		}
	}
}
