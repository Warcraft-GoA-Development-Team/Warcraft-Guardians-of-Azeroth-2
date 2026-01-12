You can define

== Structure ==

name_of_the_position = {
	# Main skill to look into the character list. If none the best sumk of all the skills will be at the top.
	skill = diplomacy
	auto_fill = yes/no/{ <triggers> } # Will automatically be filled, without the player being able to select who takes the position. Trigger scope: council owner character. Default: no. An empty trigger is treated as 'no'.
	fill_from_pool = yes/no # default = no. Only relevant when auto_fill is true or trigger. Will either fill from pool, otherwise from Court and Vassals.
	is_clergy_position = yes/no # default = no. If this is true - this council position will be part of the character counted as clergy.
	inherit = yes/no/{ <triggers> } #  Position will be inherited by the primary heir if that character is valid to hold the position. Trigger scope: council owner character. Default: no. An empty trigger is treated as 'no'.
	can_fire = yes/no/{ <triggers> } # The councillor can be fired. Trigger scope: council owner character. Default: yes. An empty trigger is treated as 'yes'.
	can_reassign = yes/no/{ <triggers> } # The councillor can be reassigned. Trigger scope: council owner character. Default: yes. An empty trigger is treated as 'yes'.
	can_change_once  = yes/no/{ <triggers> } # The councillor can be assigned, but not reassigned/fired in their lifetime after the assignment. Trigger scope: council owner character. Default: no. An empty trigger is treated as 'no'.

	name = loc_key # What name to use.
	name = { # Alternatively, you can use triggered loc. SCOPE is the character's liege, event target 'councillor' is the councillor. If no character liege is provided, we fall back to the key of the position rather than going through triggered loc
		first_valid = { ... }
	}
	
	tooltip = loc_key # What string should be used when you tooltip the name of the position
	tooltip = { # Alternatively, you can use triggered loc. SCOPE is councillor, event target 'councillor_liege' is the council owner/councillor's liege.
		first_valid = { ... }
	}

	# Modifier applied to the character in this position. Can take a "scale" parameter to scale by (a script value; see _script_values.info). Up to 5 of these can be defined if more than one scale is necessary
	modifier = {
	}

	# Modifier applied to the liege of the character in this position. Can take a "scale" parameter to scale by (a script value; see _script_values.info). Up to 5 of these can be defined if more than one scale is necessary
	council_owner_modifier = {
	}
	
	# Is this an available position for this council [SCOPE is the CHARACTER owner of the council]
	valid_position = {

	}

	# Is this a valid position for a character. [SCOPE is the character applying to the position]
	# Always checked for characters showing up in the Appoint Position list and when character gets assigned to position
	valid_character = {
	}

	# Effect applied when a character gets this position.
	# scopes:
	#	root: the character applying to the position
	#	councillor_liege: the council owner
	#	swapped_position: the position that's being swapped for this one. Only exists during a councillor swap.
	#
	on_get_position = {

	}

	# Effect applied when a character lose the position. It will also be fired before on_fired_from_position when firing a councillor.
	# scopes:
	#	root: the character losing the position
	#	councillor_liege: the council owner
	#
	on_lose_position = {
	
	}

	# Effect applied when a character is fired from the position. It will be fired after on_lose_position.
	# scopes:
	#	root: the character being fired
	#	councillor_liege: the council owner
	#	new_councillor: the character that will take this position. May be empty
	#
	on_fired_from_position = {

	}
	
	use_for_scheme_phase_duration = yes/no
	use_for_scheme_resistance = yes/no
	
	# Which portrait animation should councillors of this type use in the council window
	portrait_animation = X

	# Council data used in the Barbershop's Council preset. Defines the council character's position and if it should be rendererd in front of other characters.
	barbershop_data = {
		position = { ... }
		click_to_front = yes/no
	}
}

== Related loc ==
CHARACTER.GetCouncilTitle 										- Returns the character's council position. Blank if no position
CHARACTER.GetCouncilTitlePossessive 							- Returns the character's council position in possessive form. Blank if no position
CHARACTER.GetCouncilTitleForPosition('council_position_key', council_owner_character)	- Returns what the character's council position would be named if they held the provided position
CHARACTER.GetMyCouncillorsTitle('council_position_key')			- Returns the title of the characters councillor. Default title if no councillor
COUNCIL_POSITION.GetName										- Returns the default name (the localized key) of the position
COUNCIL_POSITION.GetKey											- Returns the unlocalized key of the position
COUNCIL_POSITION.GetPortraitAnimation							- Returns the name of the portrait animation, with a fallback to the default portrait animation
