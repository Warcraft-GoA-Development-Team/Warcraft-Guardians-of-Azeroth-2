Structure:

# Diarchy type
key = {
	# trigger has to be true when diarchy starts
	start = {}

	# diarchy ends when trigger is true. Empty trigger means diarchy ends only via script
	end = {}

	# if diarchy type uses diarch succession mechanic
	succession = yes/no

	# Scripted value describing how much current candidate is preferred
	# root - is the candidate being evaluated
	candidate_score = {
		value = 0
		add = this.age
	}

	# Scripted value describing how good is the diarch overall
	# qualifications for individual mandates can be used here
	# Please avoid circular dependencies and don't use aptitude for mandate
	# qualifications
	aptitude_score = {
		add = mandate_type_qualification:some_mandate_type
	}

	# Sctipted value describing loyalty of the diarch
	loyalty_score = {
		if = {
			limit = {
				opinion = {
					target = liege
					value > 50
				}
			}
			add = 50
		}
	}

	# diarchy type allows seletion of one active mandate out of several available ones
	mandate = mandate_type_1
	mandate = mandate_type_n

	# Diarchy can have multiple power levels that unlock diarch powers
	power_level = {

		# Required scales of power swing value to activate the option
		swing = 15

		# Parameter name - dynamic token. Use together with triggers to check
		# if active diarchy has certain parameter enabled
		# can have several parameters on the same power level
		parameter = limited_power
		parameter = unlimited_power
	}

	# scales of power swing trends towards this scripted value
	# by DIARCHY_MONTHLY_POWER_CHANGE every month
	swing_balance = {
		value = 40
	}

	# character interaction is used to end this type of diarchy and accessible via diarchy window
	end_interation = interaction_name

	# Modifier applied to the liege of the character in this position
	# Can take a "scale" parameter to scale by (a script value; see _script_values.info)
	liege_modifier = {}

	# Modifier applied to the active diarch
	# Can take a "scale" parameter to scale by (a script value; see _script_values.info)
	liege_modifier = {}
}
