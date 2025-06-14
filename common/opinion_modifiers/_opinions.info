== Structure ==

opinion_key = {

	### brief: days/months/years (int, optional )
	# How long does the opinion modifier last?
	# AKA duration
	#
	days/months/years = int	

	### brief: decaying ( bool, optional )
	# Makes opinion value decay over the duration of the modifier to 0
	# Must define either monthly_change or duration
	# Mutually exclusive with growing
	#
	decaying = no

	### brief: delay_days/months/years ( int, optional )
	# How long does it take before it starts to decay?
	# May only be used if decaying = yes
	#
	delay_days/months/years = 0

	### brief: growing ( bool, optional )
	# Starts at 0 ( or min, if defined) and grows for its duration (if set)
	# or until it hits its value.
	# Must define either monthly_change or duration
	# Mutually exclusive with decaying
	#
	growing = no

	### brief: monthly_change ( fixed point, optional )
	# How much does the modifier value change each month?
	# Must be a positive number 
	# Mutually exclusive with duration (days/months/years)
	#
	monthly_change = 0.0				

	### brief: stacking ( bool, optional )
	# When set to 'yes', applying this modifier more than once increases
	# its effect rather than just resetting its duration
	#
	stacking = no

	### brief: min ( int, optional )
	# Modifier value cannot be lower than this value
	#
	min = 0 

	### brief: max ( int, optional )
	# Modifier value cannot be higher than this value
	#						
	max = 0


	### Opinion Flags

	## Punishment Reasons

	### brief: imprisonment_reason ( bool, optional )
	# Gives the Character an imprisonment reason on the target
	#
	imprisonment_reason = no

	### brief: banish_reason ( bool, optional )
	# Gives the Character an banishment reason on the target
	#
	banish_reason = no

	### brief: execute_reason ( bool, optional )
	# Gives the Character an execution reason on the target
	#
	execute_reason = no

	### brief: revoke_title_reason ( bool, optional )
	# Gives the Character an title revocation reason on the target
	#
	revoke_title_reason = no

	### brief: divorce_reason ( bool, optional )
	# Gives the Character an reason to divorce the target
	#
	divorce_reason = no


	## Mechanical Effects

	### brief: obedient ( bool, optional )
	# Makes the character obedient to the opinion target for the duration
	# of the opinion modifier
	# Both characters must use Obedience, or this parameter will do nothing
	#
	obedient = no
}
