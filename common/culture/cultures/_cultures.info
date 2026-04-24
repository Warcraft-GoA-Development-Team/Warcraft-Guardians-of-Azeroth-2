##############################################################
# Structure
#
# Cultures are templates for the cultural parameters of an ethnicity.
# These files generate the Culture database.
# Culture Templates are instanced in Cultures, and can hybridize with one another or diverge to generate new Cultures.
# As such the CultureDatabase only holds templates, and the actual cultures are stored in a dynamic CultureManager.
##############################################################

first_culture = {
	# graphical_cultures = { ... }
	
	# The color of the culture, used e.g. on the map
	color = { 1 0.5 0.2 }

	created = date # Optional creation date
	history_loc_override = key # specify a customloc key for history rather than the default one

	traditions = { key key }

	# How the name of a person of this culture behaves with respect to the dynasty.
	# When showing the person's ShortUIName, FullName, TitledName etc, some cultures would expect the dynasty to also be shown.
	# In this case we allow to override the default strings, to show name and dynasty in different orders or potentially omit data.
	# This is a free text string that will be appended to the base character localization key when localizing character names.
	# 	For instance, to change a localization string that would show the nickname:
	#		CHARACTER_FIRST_NAME_NICKNAMED: "$NAME$ $NICK$" -> Jack "the Jackal"
	#	You can decide to implement an aesthetic that always shows the dynasty before the name:
	#		CHARACTER_FIRST_NAME_NICKNAMED_NEWCONVENTION: "$DYNASTY$ $NAME$ $NICK$" -> Jackson Jack "the Jackal"
	# This convention is only relevant for characters with a dynasty: lowborns will always use the default convention.
	#
	# When using a new aesthetic convention string "NEWCONVENTION", be sure to:
	#	* use a lowercase string. It will be uppercased when generating character name strings
	#	* prefer snake_case_naming for readability
	#	* update this list if needed, so we can track which styles we currently support
	#	* add a new line in culture_gfx_l_LANGUAGE.yml with key "culture_aesthetics_naming_NEWCONVENTION" to describe the aesthetic in tooltips
	#	* add a new set of localization keys in character_l_LANGUAGE.yml with your _NEWCONVENTION suffix and rearrange tokens where required.
	#		You can avoid to specify overrides for the new convention if the resulting text would be the same as the default entry (e.g. FIRSTNAMEONLY should never change)
	#
	### Default: omit the entry
	#	* omit this entry to use the common convention used in most western europe:
	#		use the first name most of the time, when showing "full names" the dynasty name will generally be shown after the first name
	#
	#	* dynasty_always_first: used in chinese and korean cultures, the dynasty will always be shown before the first name.
	#	* dynasty_first: used in japanese cultures, the dynasty will be shown before the first name in all "full name" occurrences.
	name_order_convention = suffix

	ethos = key
	heritage = key
	language = key
	martial_tradition = key
	head_determination = key
	name_list = key			# How to name things. You can have multiple of these entries. The first one is the primary one and will be used for things like prefixes where it doesn't make much sense to randomize between the lists

	dlc_fallback_pillar = {
		# Replace with this pillar if you lack the DLC feature
		fallback = martial_custom_female_only
		requires_dlc_flag = the_northern_lords
	}
	dlc_tradition = {
		# Add this tradition if you have the DLC feature
		trait = tradition_philosopher_culture
		requires_dlc_flag = the_northern_lords
		# Add this if you don't. Optional
		fallback = tradition_blah_blah
	}

	character_modifier = {	# Modifier effects on all characters of the culture
		diplomacy = 1
	}

	ethnicities = {
		10 = german		# The weight says how common the ethnicity is within the culture
		10 = caucasian
	}

	# The first key in the sequence is used for naming the GFX culture. The sequence must be the same for every set that starts with the same GFX culture (otherwise, "western_coa_gfx some_other" and "western_coa_gfx" are impossible to differentiate)
	# For clothing and CoAs, you can have multiple sections to represent hybrids
	building_gfx = { key key key }
	clothing_gfx = { key key key }
	unit_gfx = { key key key }
	coa_gfx = { key key key }

	# brief: CoA frame for houses of this culture.
	# When using a frame "my_frame", be sure to include the following files:
	#	* my_frame.dds
	#	* my_frame_mask.dds
	# to gfx/interface/coat_of_arms/frames. See existing assets for reference.
	house_coa_frame = frame_name
	#
	dynasty_coa_frame = frame_name
}

second_culture = {
	...
}

== Triggers ==
has_building_gfx
has_clothing_gfx
has_coa_gfx
has_unit_gfx
