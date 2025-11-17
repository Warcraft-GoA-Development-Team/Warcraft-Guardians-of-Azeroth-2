##############################################################
# Structure
#
# Culture Innovations are templates for technologies bound to an era and possibly to cultural/regional requirements.
# These files generate the CultureInnovationType database. You can also interact with Culture Innovation Types as scoped objects, usually within the scope of a Culture.
# Cultures gradually unlock Innovations based on era and the skills of its Culture Head.
##############################################################


# Key of the innovation
# This will also serve as fallback localization key: the generic innovation will use its key as loc key for the name, and append "_desc" to generate the loc key for its description.
name_of_culture_innovation = {

	# key to the cultural era this innovation belongs, e.g. culture_era_early_medieval. Refer to 00_culture_eras.txt for a list of available eras.
	culture_era = key			

	# Innovation group. Can be: culture_group_military, culture_group_civic or culture_group_regional.
	group =  group_name

	# Path to the default icon to show. If not set will use the default icon defined in NGameIcons::DEFAULT_CULTURE_INNOVATION_TYPE_ICON_PATH
	icon = path		

	# The Skill the Head of Culture will use to compute fascination bonuses. Can be one of:
	#	* learning
	#	* martial
	#	* stewardship
	#	* diplomacy
	#	* intrigue
	# Set to learning by default.
	skill = skill_name

	# the weight that will be used to randomly pick the innovation when selecting Spread (for AI Culture Heads) 
	#	root = the culture head evaluating this innovation
	ai_weight_for_spread = {
		value = 1

		if = {
			limit = {
				has_trait = education_martial
			}
			add = 100
		}
	}

	#	root = culture
	# 	scope:character = cultural head
	ai_weight_for_fascination = {
		value = blah
		scope:character = {}
	}

	# Optional list of triggered assets. The innovation, when possible, will take the first asset that satisfies its trigger and use its members to style its name and icon.
	# This style is calculated on startup or when a new culture is created and then never updated.
	# When dealing with generic innovation types (that are not directly tied to a culture) this mechanism is not active.
	# The order of definition of the assets matters: put higher priority assets first.
	asset = {

		# culture-scoped trigger for deciding whether a culture is supposed to use this asset.
		# please base this trigger on static data related to the culture, like aesthetics or heritage.
		# We don't guarantee that the game is in a fully completed state during evaluation.
		trigger = {}

		# the base loc key to use in this case. optional, but at least one between name and icon must be defined.
		name = culture_specific_name

		# the icon to use in this case. optional, but at least one between name and icon must be defined.
		icon = path_to_culture_specific_icon
	}

	# Optional key of the region where this innovation can start getting base progress.
	# If defined, the culture needs to be present in a minimum number of provinces in this region in order to be eligible.
	# Empty means anywhere.
	region = key

	# Trigger to check if it can be unlocked by the culture. In contrast to can_progress it will be hidden otherwise. Scope: culture Default: always = yes
	potential = {}

	# To check if it can start being exposed. Scope: culture Default: always = yes
	can_progress = {}

	# Modifiers of this culture innovation. This will be applied to the characters of that cuture.
	character_modifier = {}
	
	# Modifier of this culture innovation applied to the culture itself.
	culture_modifier = {}

	# Modifier of this culture innovation applied to counties of the culture.
	county_modifier = {}

	# Modifier of this culture innovation applied to provinces in a county of the culture.
	province_modifier = {}

	# optionally add parameters to the innovation. They are defined in the same way as traits and traditions, and can be queried via script triggers.
	parameters = {

		# Only boolean parameters are currently supported
		parameter_name = yes/no
	}

	# Optional flag, relevant for the has_all_innovations trigger. Can list any number of flags for each innovation.
	flag = flag_name

	# key of a building that can be unlocked. There can be more than one. This is only to show on the tooltip, it has to be manlually blocked on the object itself.
	unlock_building	= key
	# key of a decicion that can be unlocked. There can be more than one. This is only to show on the tooltip, it has to be manlually blocked on the object itself.
	unlock_decision = key
	# key of a casus belli that can be unlocked. There can be more than one. This is only to show on the tooltip, it has to be manually  blocked on the object itself.
	unlock_casus_belli = key
	# key of a regiment that can be unlocked. There can be more than one. Actually does unlock the MaA.
	unlock_maa = key
	# key of a law that can be unlocked. There can be more than one. This is only to show on the tooltip, it has to be manually  blocked on the object itself.
	unlock_law = key
	# A custom effect description that will be added to the list of effects. You can specify more than one.
	custom = loc_key
	
	# Optional upgrades to existing MaA. You can specify more than one.
	maa_upgrade = {
		# The base MaA type to upgrade
		type = cavalry
		damage = 0.1
		toughness = 0.1
		pursue = 0.1
		screen = 0.1
		siege_value = 0.1
		max_size = 1
	}
}

### Innovation flags:
#	flag = global_maa
#	flag = global_regular
#	flag = tribal_era_regular
#	flag = early_medieval_era_regular
#	flag = high_medieval_era_regular
#	flag = late_medieval_era_regular
#
#	flag = global_regional
#	flag = tribal_era_regional
#	flag = early_medieval_era_regional
#	flag = high_medieval_era_regional
#	flag = late_medieval_era_regional
#
#	flag = silk_road_innovation
