<key> = {
	# Should this legitimacy type apply to this playable ruler, evaluated daily for the player, yearly for AI
	# First valid one is selected
	# root = ruler character
	is_valid = {
		<triggers>
	}

	# What level the AI expects of a liege with this legitimacy type
	# root = vassal
	# scope:liege = liege character
	ai_expected_level = {
		<script value>
	}

	# Opinion change for a vassal of their liege for each level below the vassal's expected legitimacy the liege is
	# root = opinion holder, person who has an opinion of target
	# scope:target = opinion target, aka the liege
	below_expectations_opinion = <script_value>

	# Maximum value of legitimacy of this type, should be larger than the last threshold
	max = <script_value>

	# Multiple levels can be read in, the last one a ruler is >= will be the applied level
	# First level must have a threshold of 0
	level = {
		# root = ruler character
		threshold = <script_value>

		# Effect run when gaining this legitimacy level
		# root = ruler character
		on_level_entered = {
			<effects>
		}

		# Dynamic description for the on_level_entered effect
		# root = ruler character
		on_level_entered_desc = {
			first_valid = {
			}
		}

		modifier = {
			# What modifiers are applied
			<modifiers>
		}

		# Flags to be checked with has_legitimacy_flag
		# Multiple can be read in
		flag = <flag_name>
	}

	level = {
		...
	}
	level = {
		...
	}
}
