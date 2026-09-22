domicile_type = {
	# Is this domicile type allowed for character
	# root = character
	allowed_for_character = {
		<triggers>
	}

	# Shortcut to rename the domicile window
	# Rename windows are: 'primary_title' or 'house'. Default type is 'none'
	rename_window = none

	# Texture used in the realm tab access
	illustration = "path/to/image.dds"

	# Flat icon texture representing the domicile type in various places
	icon = "path/to/image.dds"

	# Texture for map pin
	map_pin_texture = "path/to/image.dds"

	# Where to anchor the domicile map pin in relation to it's province
	# Anchor types are: 'up' or 'right'. Default type is 'right'
	map_pin_anchor = right

	# Will this domicile show up in the game lobby
	map_pin_lobby = yes

	# Does this domicile manage the provisions resource
	# Domiciles that use provisions travel to a new location, otherwise it's moved instantly
	provisions = no

	# Is this domicile allowed to travel?
	travel = no

	# Does this domicile manage the herd resource
	herd = no

	# Does this domicile store a culture and faith? (default: no)
	culture_and_faith = no

	# Should this domicile also move when you move your realm capital? (default: no)
	move_with_realm_capital = no

	# Can you move this domicile without bespoke features?
	#
	can_move_manually = yes

	# After moving the domicile, how many days before you can move again?
	# days/weeks/months/years = X
	move_cooldown = { days = 7 }

	# How much does it cost to move the domicile? Ex: { gold = 500, prestige = 100 }
	move_cost = {
		<scripted_cost>
	}

	# Modifier applied to the domicile owner when disliked by the majority of their court
	# Can take a "scale" parameter to scale by (a script value; see _script_values.info)
	domicile_temperament_low_modifier = {}

	# Modifier applied to the domicile owner when liked by the majority of their court
	# Can take a "scale" parameter to scale by (a script value; see _script_values.info)
	domicile_temperament_high_modifier = {}

	# How many unlocked external building slots domicile starts out with
	base_external_slots = 2

	# List all available main and external slots, they will be unlocked in order of appearance here
	# Note: Internal slots are handled separately by the buildings themselves
	#       Layering of slots (in front/behind) matches order of definition
	domicile_building_slots = {
		main_slot = { # any name you want
			# Set what domicile building may be constructed here based on their slot type
			# Types are: 'main' or 'external'. The 'internal' slot type is handled within the buildings themselves
			# Main buildings without a previous building will attempt to be constructed automatically in found main slots
			# Default type is 'external'
			slot_type = main

			# Building position in the domicile window, supports both % and direct values
			position = { ... }

			# Size of buildings placed in this slot, supports both % and direct values
			size = { ... }

			# Define assets used when slot is empty, will pick first valid match
			empty_slot_asset = {
				# Trigger for scoped domicile when to pick this asset over another, remove trigger part to always pick this asset
				trigger = { ... }

				# Building icon used in UI
				icon = "path/to/image.dds"

				# Path to texture shown in the domicile window
				texture = "path/to/image.dds"

				# Mask used with texture
				intersectionmask_texture = "path/to/mask.png"
			}

			# Define assets used when building is under construction in this slot, will pick first valid match
			construction_slot_asset = {
				# Trigger for scoped domicile when to pick this asset over another, remove trigger part to always pick this asset
				trigger = { ... }

				# Building icon used in UI
				icon = "path/to/image.dds"

				# Path to texture shown in the domicile window
				texture = "path/to/image.dds"

				# Mask used with texture
				intersectionmask_texture = "path/to/mask.png"
			}
		}
		external_slot_1 = { # any name you want
			...
		}
	}

	# What background assets does the domicile use, will pick first valid match
	domicile_asset = {
		# Trigger for scoped domicile when to pick this asset over another, remove trigger part to always pick this asset
		trigger = { ... }

		# Path to background texture shown in the domicile window
		background = "path/to/image.dds"

		# Path to foreground texture shown in the front of domicile window
		foreground = "path/to/image.dds"

		# Path to ambience sound
		ambience = "path/to/ambience"
	}

	# Map entity for the domicile, multiple can be read in, first one is picked from order they are read in.
	#
	# If the location of the domicile has no holding, it takes the place of the holding (on the 'Buildings' locator).
	# Else they will be placed on the 'Activity' locator, but only if there is nothing there at that time.
	map_entity = {
		# root = the domicile
		# scope:owner = domicile owner
		trigger = {
			<triggers>
		}
		reference = "name" # Entity name
	}
	map_entity = "name" # Short hand for a single constant entity name
}
