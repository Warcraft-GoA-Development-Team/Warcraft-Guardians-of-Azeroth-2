##############################################################
# Structure 
##############################################################

### Brief: key ( string )
# Defines a Court Type to a key. 
#
# The order individual court types are defined in here determines the order
# they are displayed in the UI dropdown list of selectable court types. I.e.
# settings defined first are displayed at the top, and those defined last are
# displayed at the bottom.
court_type_name = {

	### Brief: default ( bool )
	# Which court type is the default when initializing new courts. Only one
	# Court Type may have this turned to yes. 
	#
	# Default: no
	default = no
	
	### Brief: background ( string )
	# Path to texture to use as background texture in the interface when
	# referring to this court type.
	background = "gfx/interface/icons/culture_pillars/background.dds"

	### Brief: is_shown ( trigger )
	# The trigger deciding whether or not to show this court type in the
	# selection list.
	#
	# Supported scopes:
	#		root ( Character ) 
	#			Court owner evaluating this court type.
	is_shown = { ... } 							

	### Brief: is_valid ( trigger )
	# The trigger deciding whether or not the court type is selectable in the 
	# court type list, if it's showing.
	#
	# Supported scopes:
	#		root ( Character ) 
	#			Court owner evaluating this court type.
	is_valid = { ... }							

	### Brief: level_perk 
	# The bonuses associated with one level of court grandeur. These levels 
	# are cumulative as the court level increases. Define each level separately.
	level_perk = {

		### Brief: court_grandeur ( integer )
		# At which level of grandeur this bonus should come into effect.
		court_grandeur = 1				
		
		### Brief: owner_modifier ( modifiers )
		# Modifier applied to the owner of the court when amenities are at 
		# this setting.
		owner_modifier = { ... }
		
		### Brief: courtier_guest_modifier ( modifiers )
		# Modifier applied to the courtiers and guests when court amenities
		# are at this setting. 
		courtier_guest_modifier = { ... }

		### Brief: owner_modifier_description ( localization key )
		# Localization to show in addition to the owners modifier description.
		# Prepends a EFFECT_LIST_BULLET to the entry. If multiple entries are 
		# defined in the loc key, individual newlines and EFFECT_LIST_BULLET 
		# must be specified within. 
		owner_modifier_description = LOCKEY 

		### Brief: courtier_guest_modifier_description ( localization key )
		# Localization to show in addition to the courtier/guest modifier 
		# description. Prepends a EFFECT_LIST_BULLET to the entry. If multiple 
		# entries are defined in the loc key, individual newlines and 
		# EFFECT_LIST_BULLET must be specified within. 
		courtier_guest_modifier_description = LOCKEY 
	}
	level_perk = {
		court_grandeur = 2
		...
	}

	### Brief: time_perk 
	# Bonuses applied to courtiers that spend time in the court for a period of 
	# time. Define each level separately. 
	time_perk = {

		### Brief: required_months_in_court ( integer )
		# Number of months spent in this court required to gain the bonus.
		required_months_in_court = 12 	
		
		### Brief: owner_modifier ( modifiers )
		# Modifier applied to the owner of the court when amenities are at 
		# this setting
		owner_modifier = { ... }
		
		### Brief: courtier_guest_modifier ( modifiers )
		# Modifier applied to the courtiers and guests when court amenities
		# are at this setting
		courtier_guest_modifier = { ... }
		
		### Brief: owner_modifier_description ( localization key )
		# Localization to show in addition to the owners modifier description.
		# Prepends a EFFECT_LIST_BULLET to the entry. If multiple entries are 
		# defined in the loc key, individual newlines and EFFECT_LIST_BULLET 
		# must be specified within. 
		owner_modifier_description = LOCKEY 

		### Brief: courtier_guest_modifier_description ( localization key )
		# Localization to show in addition to the courtier/guest modifier 
		# description. Prepends a EFFECT_LIST_BULLET to the entry. If multiple 
		# entries are defined in the loc key, individual newlines and 
		# EFFECT_LIST_BULLET must be specified within. 
		courtier_guest_modifier_description = LOCKEY 
	}
	time_perk = {
		required_months_in_court = 24
		...
	}

	### Brief: cost ( scripted cost )
	# How much it costs to change to this court type.
	cost = { 
		gold = { ... }
		prestige = { ... }
		piety = { ... }
	}

	### Brief: ai_will_do ( scripted integer value )
	# Script value in ruler scope. If above 0, the AI will try to set the court
	# type to this if able. Court types are decided in the RARE_TASK_TICK. If 
	# multiple court types are possible, the AI will enact the one with the 
	# highest score, with a bias towards the currently active one of 
	# CURRENT_COURT_TYPE_SETTING_ADDED_WEIGHT to prevent switching back and
	# forth to closely scored options
	# 
	# Supported scopes:
	#		root ( Character )
	#			Court owner evaluating this court type.
	ai_will_do = { ... }				
}

##############################################################
# Triggers 
##############################################################

### Brief: has_court_type
# Does the scoped character have this court type?
scope:my_character = {
	has_court_type = court_type_name
}

### Brief: has_same_court_type_as
# Does the scoped character have the same court type as target character?
scope:my_character = {
	has_same_court_type_as = scope:other_character
}

##############################################################
# Effects 
##############################################################

### Brief: set_court_type
# Set the court type of the scoped character's royal court.
scope:my_character = {
	set_court_type = court_type_name
}

##############################################################
# Localization 
##############################################################

The key of the type will be used as its key in localization.
