##############################################################
# Structure 
##############################################################

activity_locale_type = {

	### Brief: is_available ( trigger )
	# Trigger to check if this locale type is valid for the activity.
	#
	# Supported scopes:
	#		root ( Character )
	#			Character picking the option
	#		scope:host  ( Character )
	#			Character hosting the activity
	#		scope:activity ( Activity ) 
	#			The activity itself
	#
	is_available = { ... }

	### Brief: chance ( scripted value int32 )
	# How likely is this locale to be picked to fill a locale slot?
	# Will be picked by weighted random.
	#
	# Supported scopes:
	#		root ( Character )
	#			Character picking the option
	#		scope:host  ( Character )
	#			Character hosting the activity
	#		scope:activity ( Activity ) 
	#			The activity itself
	#
	chance = { ... }
	
	### Brief: on_enter_locale ( effect )
	# Effect firing to execute event in the locale
	#
	# Supported scopes:
	#		root ( Character )
	#			Character interacting with the effect
	#		scope:host  ( Character )
	#			Character hosting the activity
	#		scope:activity ( Activity ) 
	#			The activity itself
	#
	on_enter_locale = { ... }

	### Brief: ai_will_do ( scripted value int32 )
	# How likely is the AI to pick to visit this locale?
	# Will be picked by weighted random.
	#
	# Supported scopes:
	#		root ( Character )
	#			Character picking the option
	#		scope:host  ( Character )
	#			Character hosting the activity
	#		scope:activity ( Activity ) 
	#			The activity itself
	#
	ai_will_do = { ... }

	### Brief: cooldown - duration
	# How many days is the locale invalid to be 'entered', after it has been 
	# entered.
	#
	# Supported scopes:
	#	See on_enter_locale
	#
	cooldown = { days = 7 }

	### Brief: visuals ( triggered reference block )
	# Visual widgets for the locale, multiple can be read in, first one is 
	# picked from order they are read in. Reference is a file name (and top 
	# level widget name) in gui/activity_locale_widgets
	#
	visuals = {
		# root = the activity
		# scope:activity = the activity
		# scope:host = host of the activity
		trigger = {
			<triggers>
		}
		reference = "name" # Plug in widget name
	}

	visuals = "name" # Short hand for a single visual
}

##############################################################
# Localization 
##############################################################

Localize the locale type's key: 
 activity_locale_type: "Activity Locale Type"
 activity_locale_type_desc: "This is the description of the Activty Locale Type that will show up in tooltips and other elements. "
