# Ruler objective advice enables guided learning by doing for new players.
#
# Every entry is a piece of advice to evaluate for all titles in the
# geographical region associated with the objective (decision).
#
# Shared scopes:
# root –  Decision taker (player character).
# title – The title to evaluate.
# doing - Is the player already doing this? (added after the corresponding trigger)
#
<advice key> = {

	### Brief: decisions
	# Objective decisions this piece of advice is applicable to.
	decisions = { ... }

	### Brief: is_valid_advice
	# Trigger – Is this at all relevant advice?
	is_valid_advice = {
		debug_only = <yes/no>
	}


	### Brief: is_doing
	# Is the player currently doing what this advice recommends with the provided title?
	#
	# The result of this trigger is added to the scope as 'doing',
	# and is available to all evaluations below this one.
	# Advice that the player is already following is always preferred
	# over new recommendations.
	#
	is_doing = {
		always = <yes/no>
	}

	### Brief: is_valid_for_title
	# Trigger – Is this title relevant for this piece of advice?
	is_valid_for_title = {
		always = <yes/no>
	}

	### Brief: relevance
	# How valuable this this advice with the given title.
	#
	# Higher value is better advice, and top ones are presented to the player.
	# Advice where the best variants relevance is lower than the define
	# ADVICE_RELEVANCE_LIMIT (default 0) is ignored entirely.
	#
	relevance = <script value>

	### Brief: summary
	# Short 'call to action' displayed on the advice button in the UI.
	summary = <dynamic desc>

	### Brief: description
	# Detailed explanation on what the player is advised to do,
	# how to do it, and why it is may be a good idea.
	description = <dynamic desc>
}
