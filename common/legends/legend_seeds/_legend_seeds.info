
### Brief: legend_seed
# Pre-scripted legend seed that characters can use to start a legend
#
<key> = {
	
	### Brief: quality ( enum )
	# Quality of the legend seed 
	#
	quality = famed/illustrious/mythical

	### Brief: type ( database key  )
	# String key to a legend type defined in legends/legend_types
	#
	type = <legend_types_key>

	### Brief: is_shown ( trigger )
	# Is this seed shown to the scoped character?  
	#
	# Supported scopes:
	#		root ( Character )
	is_shown = {
		<triggers>
	}

	### Brief: is_valid ( trigger )
	# Is the scoped character valid for this seed? 
	#
	# Supported scopes:
	#		root ( Character )
	is_valid = {
		<triggers>
	}

	# What chronicle is this legend seed using
	chronicle = <key>

	# What each property should be set to when created
	# Each property defined on the chronicle must be set here
	# root = the creator of the legend
	chronicle_properties = {
		<key> = <scope>

		# Optionally a trigger can be set, the first property evaluated true with a trigger will be used for that property slot
		# You must still set one of each property, the triggers can not end up meaning a property is unset
		<key> = {
			target = <scope>
			is_valid = {
				<triggers>
			}
		}
	}

	# What each chapter should use as the loc key, this overrides the default loc keys if set
	# Can be ignored to not set any overrides
	chronicle_chapters = {
		<key> = <loc_key>
	}
}