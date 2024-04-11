#TESTING: Use spawn_epidemic smallpox 2595 apocalyptic to spawn an epidemic

<key> = {
	trait = <trait_key> # What trait is tied to this disease

	color = <color> # What color this epidemic has on the map: takes color names defined in the script colors file, RGB, HSV, HSV360 and HEX
	# color = red // color = { r g b } // color = hex { your_hex }

	# Name of the epidemic
	# defaults to epidemic_key
	# root = the epidemic being created
	name = {
		<dynamic_description>
	}

	# Multiplier used against intensity level for how important an epidemic is 
	# Used for picking which to show on the map
	priority = <value>

	# Data passed to the shader
	shader_data = {
		strength = 0-1 # Strength of the disease, unsigned normalized float
		edge_fade = 0-1 # Edge fade out, unsigned normalized float
		tile_multiplier = 0-1 # Multiplier for the tile wrapping
		texture_index = 0 # Which tile texture in the shader to use
		channel = red/green/blue/alpha # Which color channel to use in the texture
	}

	# Can a character be infected with this epidemic
	# root = potential character to infect
	# scope:epidemic = the epidemic
	can_infect_character = {
		<triggers>
	}

	# Monthly chance for an epidemic to infect a character in the province, ran once per character
	# % from 0-100 inclusive
	# root = potential character to infect
	# scope:epidemic = the epidemic
	character_infection_chance = {
		<script value>
	}

	# Effect run when a character is infected with this epidemic
	# root = character being infected
	# scope:epidemic = the epidemic
	on_character_infected = {
		<effects>
	}

	# Effect run when a province is infected with this epidemic
	# root = province being infected
	# scope:epidemic = the epidemic
	on_province_infected = {
		<effects>
	}

	# Effect run when a province recovers from this epidemic
	# root = province being infected
	# scope:epidemic = the epidemic
	on_province_recovered = {
		<effects>
	}

	# Effect run when a province spawns an outbreak of this epidemic
	# root = the epidemic
	on_start = {
		<effects>
	}

	# Effect run on rulers of the provinces affected by the epidemic on monthly 
	# tick.
	# root = the ruler being affected
	# scope:epidemic = the epidemic
	on_monthly = {
		<effects>
	}

	# Effect run when an epidemic of this type ends
	# root = the epidemic
	on_end = {
		<effects>
	}

	# Every province has an infection level from 0-100, the highest level there they are above the threshold of
	# will have its modifiers applied
	infection_levels = {
		# Left hand side value can reference a named script value that has a constant value ie: no formulas
		<value> = {
			# Modifier applied to any province infected
			province_modifier = {
				<modifier>
			}

			# Modifier applied to the county if its county capital province is infected
			county_modifier = {
				<modifier>
			}

			# Modifier applied to every ruler that has this province as a part of their de facto realm hierarchy
			# This means its effects will be stacked on a ruler for every infected province
			realm_modifier = {
				<modifier>
			}
		}
	}

	outbreak_intensities = {
		# Intensity levels are minor, major and apocalytpic, each can be read in separately
		# Higher intensity levels are kept when neighboring epidemics merge.

		minor = {
			# Should an outbreak of this intensity be considered a global event that notifies the player regardless
			# of their proximity to the outbreak
			# Defaults to no
			global_notification = yes/no

			# Chance for an outbreak of this intensity to spawn on a province per year
			# % from 0-100 inclusive
			# root = potential province
			# scope:epidemic_type = this epidemic type
			outbreak_chance = {
				<script value>
			}

			# Chance for an epidemic of this intensity to spread to an adjacent province per month
			# % from 0-100 inclusive
			# root = potential province
			# scope:epidemic = the epidemic
			spread_chance = {
				<script value>
			}

			# Maximum number of provinces an epidemic of this intensity can infect
			max_provinces = <script_value>

			# How long an infection in a province lasts for once it hits max infection
			# root = infected province
			# scope:epidemic = the epidemic
			infection_duration = {
				<scripted_duration>
			}

			# How many days it will take for a province to hit max infection
			# root = infected province
			# scope:epidemic = the epidemic
			infection_progress_duration = {
				<scripted_duration>
			}

			# How many days it will take for a province to recover from max infection after infection_duration has elapsed
			# root = infected province
			# scope:epidemic = the epidemic
			infection_recovery_duration = {
				<scripted_duration>
			}
		}
	}
}
