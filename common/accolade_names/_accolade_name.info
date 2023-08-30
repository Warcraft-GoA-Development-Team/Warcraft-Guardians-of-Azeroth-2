# Accolade Names are used to create dynamic names given the Acclaimed Knight, Owner and Primary Type of an Accolade

accolade_name = {
	# the base loc key that will be used when generating this name
	# the key can have any format but each replacement option needs to be numbered and formatted as $OPTION_X$
	key = loc_key_with_$OPTION_1$_and_$OPTION_2$

	# the number of expected options, if this mismatches with the below number of scripted options the system will error
	num_options = 3 

	# the replacement options that will be used IN ORDER to replace the $OPTION_X$ fields in the loc key
	# root = acclaimed_knight
	# event_targets = owner, accolade_type
	option = {
		# dynamic_desc with triggers and checks to pick whatever is the best option for the first replacement
		
		# for the actual desc localization the available data is structured as...
		# CHARACTER = acclaimed_knight
		# TARGET_CHARACTER = owner
		# NOTE: accolade_type is not directly accessible in the desc key and should only be used for option triggers
	}

	option = {
		# same but for the second
	}

	...

	# root is the acclaimed knight
	# scope:owner is the accolade owner
	# scope:accolade_type is the primary attribute
	potential = {
		# trigger to make sure we don't pick a key that is specific for ex. a region
	}

	# scripted value that will be used as weight when randomly picking between potential names
	# scope setup is the same as potential = {}
	weight = { value = 100 }
}
