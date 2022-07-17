All lifestyle focuses belong to a lifestyle. Using such a focus will provide experience for that lifestyle.

key = {
	is_highlighted = { ... }	# Trigger in character scope. See notes on triggers below.

	is_valid_showing_failures_only = { } # Trigger in character scope. See notes on triggers below.
	is_valid = { } # Trigger in character scope. See notes on triggers below.
	
	xp_per_level = 1000			# How much XP do you need per perk point?
	base_xp_gain = 10			# How much XP do you get each month? Before modifiers
	
	icon = some_key				# What key to use for the icon; if not defined, will use the key of the lifestyle
}

Triggers
========
Any triggers that are part of the lifestyle script files cannot use:
* scripted triggers, effects, or modifiers
* triggers, effects, or modifiers that are generated based on scripted content, such as:
	* diplomacy_lifestyle_perk_points trigger (based on a scripted lifestyle)
	* has_relation_rival trigger (based on a scripted relation)

Generated loc keys
==================
key + _name
key + _desc
key + _highlight_desc
