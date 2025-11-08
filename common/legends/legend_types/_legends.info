#TESTING: Use effect create_legend = { type = heroic quality = famed } to create a legend

<key> = {
	color = <color> # What color this legend has on the map: takes color names defined in the script colors file, RGB, HSV, HSV360 and HEX
	# color = red // color = { r g b } // color = hex { your_hex }

	# Effect run when a province adopts this legend
	# root = province being added
	# scope:legend = the legend
	on_province_spread = {
		<effects>
	}

	# Effect run when a province removes  this legend
	# root = province being removed
	# scope:legend = the legend
	on_province_recovered = {
		<effects>
	}

	# Effect run when a legend of this type is created
	# root = the legend
	on_start = {
		<effects>
	}

	# Effect run when a legend of this type is destroyed
	# root = the legend
	on_end = {
		<effects>
	}

	# Effect run on every promoter (including owner) once a year
	on_yearly = {
		<effects>
	}

	# Effect run on promoter, not owner, when they start promoting the legend
	# root = promoter to be
	# scope:legend = legend that is being promoted
	on_legend_start_promote = {
		<effects>
	}

	# Effect run on promoter, not owner, when they stop promoting the legend
	# root = former promoter
	# scope:legend = legend that was being promoted
	on_legend_stop_promote = {
		<effects>
	}

	# Protagonist are pre-filtered to be you or a member of your close and extended family

	# root = potential protagonist character
	# scope:creator = the character creating a legend of this type
	is_valid_protagonist = {
		<trigger>
	}

	# root = potential protagonist character
	# scope:creator = the character creating a legend of this type
	ai_protagonist_weight = {
		<script value>
	}

	quality = {
		# Quality levels are famed, illustrious and mythical, each can be read in separately
		famed = {
			# Chance for an legend of this quality to spread to an adjacent province per month
			# % from 0-100 inclusive
			# root = potential province
			# scope:legend = the legend
			spread_chance = {
				<script value>
			}

			# Maximum number of provinces an legend of this quality can infect
			# Higher quality levels must have >= max provinces than the previous one and be > 0
			max_provinces = <constant/named_value>

			# Monthly cost for owning a legend of this quality level
			# root = character owning
			owner_cost = {
				<scripted_cost>
			}

			# Monthly cost for promoting a legend of this quality level
			# root = character promoting
			# scope:legend = the legend
			promoter_cost = {
				<scripted_cost>
			}

			# Cost for creating a legend of this quality level
			# root = character creating
			creation_cost = {
				<scripted_cost>
			}

			# Cost for upgrading a legend to this quality level
			# root = character upgrading
			upgrade_cost = {
				<scripted_cost>
			}

			# If the legend stops being sponsored (if it becomes unowned or is completed), how long until provinces start getting removed from the legend
			removal_duration = {
				<duration>
			}

			impact = {
				# Modifier applied to any province with this legend if it's inside the realm of the owner or promoter
				province_modifier = {
					<modifier>
				}

				# Modifier applied to the county if its county capital province has adopted this legend
				county_modifier = {
					<modifier>
				}

				# Modifier applied to the owner of the legend
				owner_modifier = {
					<modifier>
				}

				# Modifier applied to every promoter of the legend
				promoter_modifier = {
					<modifier>
				}

				# Effect run when this legend is completed/ended by its owner
				# root = legend owner
				# scope:protagonist = the legend protagonist
				# scope:<property> = scope object for that property
				on_complete = {
					<effect>
				}
			}

			# Ai chances
			ai_chance = {
				# root = character with the legend seed
				create = <script value>

				# root = character who can promote
				# scope:legend = the legend to promote
				promote = <script value>

				# root = character who can take a legend
				# scope:legend = the legend to take ownership
				take_unowned = <script value>

				# root = legend owner
				# scope:legend = the legend
				upgrade = <script value>

				# root = legend owner
				# scope:legend = the legend
				# scope:can_afford_current_level (yes/no) = if the owner can currently afford the current levels monthly costs
				complete = <script value>
			}
		}
	}
}
