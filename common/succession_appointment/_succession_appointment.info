
#######################################################################
# Structure
#######################################################################

key = {

	# fixed point script value that determines base candidate score
	# root - appointment candidate
	# scope:title - title for appointment
	candidate_score = {
		value = 0
	}

	# categories of people that are by default eligible to be in succession for the title
	#
	default_candidates = { holder_close_family landed_vassal }

	# Meritocratic appointment where default candidates are all eligible people of certain level
	# Supported level sources are currencies with levels
	# If level is set, default_candidates are ignored
	#
	level = merit/prestige/piety/influence

	### brief: allow_children ( bool )
	# Whether or not to allow children to be evaluated for this succession
	#
	allow_children = no

	### brief: allow_same_tier_candidates ( bool )
	# Whether or not to allow candidates that already hold a title of the same tier
	#
	allow_same_tier_candidates = no
}

# Available categories for candidates are:
#	holder_close_family
#	holder_close_extended_family
#	holder_house_member
#	landed_vassal							# it includes holder's own vassals and peer vassals of holder
#	landed_vassal_close_family
#	landed_vassal_close_extended_family
#	landed_vassal_house_member
#	unlanded_noble_house_head				# it includes holder's own noble vassals and peer vassals of holder
#	unlanded_noble_close_family
#	unlanded_noble_close_extended_family
#	unlanded_noble_house_member
#	holder_councilor
#	holder_court_position
#	direct_subject
