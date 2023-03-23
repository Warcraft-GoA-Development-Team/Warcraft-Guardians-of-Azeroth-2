##############################################################
# Structure 
##############################################################

court_amenities_category_name = {

	### Brief: default ( string )
	# Optional specification of what counts as the default setting. New rulers 
	# will by default start with court amenities at this setting for this 
	# category. If it is not set, it will pick the first defined setting below.
	default = court_amenities_setting_name 	
	
	### Brief: key ( string )
	# Defines a court amenity setting within this category.  
	#
	# The order individual settings are defined in here determines the order 
	# they are displayed in in the UI. I.e. settings defined first are 
	# displayed to the left, and those defined last are displayed to the right.
	court_amenities_setting_name = {

		### Brief: owner_modifier ( modifiers )
		# Modifier applied to the owner of the court when amenities are at this
		# setting.
		owner_modifier = { }

		### Brief: owner_modifier_description ( localization key )
		# Localization key reference to text that should display in combination
		# with the modifier effect breakdown when the bonus is not just a 
		# modifier, but a constant effect. 
		#
		# Example entry in example_l_english.yml: 
		# 	EXAMPLE_DESCRIPTION: "More likely to attract skilled guests."
		owner_modifier_description = EXAMPLE_DESCRIPTION
		
		### Brief: courtier_guest_modifier ( modifiers )
		# Modifier applied to the courtiers and guests when court amenities are 
		# at this setting.
		courtier_guest_modifier = { }

		### Brief: courtier_guest_modifier_description ( localization key )
		# Localization key reference to text that should display in combination
		# with the modifier effect breakdown when the bonus is not just a 
		# modifier, but a constant effect. 
		#
		# Example entry in example_l_english.yml: 
		# 	EXAMPLE_DESCRIPTION: "Higher stress loss from participating in feasts."
		courtier_guest_modifier_description = localization_tag 
		
		### Brief: ai_will_do ( script value int32 )
		# Determines if the AI will select this setting or not. Evaluation is
		# done in the RARE_TASK_TICK. 
		#
		# If multiple amenity levels are possible, the AI will enact the one 
		# with the highest score, with a bias towards the currently active one 
		# of CURRENT_COURT_AMENITY_SETTING_ADDED_WEIGHT to prevent switching 
		# back and forth to closely scored options.
		#
		# The AI tries to get the single-level increase that gives the biggest
		# increase in score. This means that you want the scores to gradually 
		# become smaller, or the AI will go far down one path ignoring all the
		# rest.
		#
		# Supported scopes: 
		#		root ( Character )
		#			Owner of the Court applying the settings. 
		ai_will_do = { ... }	

		### Brief: can_pick ( trigger )
		# Trigger to check if the scoped character can pick this setting. Make 
		# sure that there are no gaps in tiers here.
		#
		# Note that these triggers MUST be repeated to higher tiers because the
		# AI does not skip levels when adjusting court amenities, it goes level
		# by level both up and down. 
		#
		# Supported scopes:
		#		root ( Character )
		#			Owner of the Court applying the settings. 
		can_pick = { ... }					 
	}										
	
	another_court_amenities_setting_name = {}
}

##############################################################
# Effects 
##############################################################

# Sets the amenity type to the given value for the scoped character.
#
# Supported scopes: 
#		root ( Character )
#			Owner of the Court applying the settings. 
set_amenity_level = {
	type = setting
	value = 2
}

# Increases the amenity type by given level for the scoped character.
#
# Supported scopes: 
#		root ( Character )
#			Owner of the Court applying the settings. 
add_amenity_level = {
	type = setting
	value = 2
}

##############################################################
# Localization 
##############################################################

The key of the setting or category will be used as its key in localization.

##############################################################
# Other notable things 
##############################################################

The amenity cooldown is defined by the court_amenity_cooldown_months script
value.
