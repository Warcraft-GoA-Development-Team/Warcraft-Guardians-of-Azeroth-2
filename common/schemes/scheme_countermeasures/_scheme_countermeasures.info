== Structure ==

countermeasure_type = {

	# Requirements that must be fulfilled by a ruler for them to be able to even see this countermeasure.
	# root: ruler
	is_shown = <trigger>

	# Requirements that must be filled by a ruler for them to be able to select this countermeasure.
	# Missing requirements are displayed in a tooltip.
	# root: ruler
	is_valid_showing_failures_only = <trigger>

	# Effects applied when countermeasure is activated.
	# root: ruler
	on_activate = <effect>

	# Cost deducted when activating this countermeasure
	# Missing resources are displayed in a tooltip.
	# root: ruler
	activation_cost = <costs>

	# Modifiers applied to the ruler that activated the countermeasure, but not any of their courtiers or guests.
	# (mainly intended as a 'cost' and only applied to the court ruler)
	owner_modifier = <modifier>

	# AIs countermeasure preference
	# An AI characters will now and then reevaluate what countermeasure to use,
	# and pick the one with the highest calculated value.
	ai_will_do = <script value>

	# Arbitrary parameters that can be checked with the trigger 'has_scheme_countermeasure_parameter'.
	# Note: the only available trigger checks for existence, so it does not matter if the value is set to 'yes' or 'no'.
	parameters = {
		some_parameter = yes
	}
}
