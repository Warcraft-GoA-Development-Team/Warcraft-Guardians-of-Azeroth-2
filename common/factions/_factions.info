== Structure ==
This documentation does not currently include all possible parameters due to the limited knowledge of the author.


# Identifier for the faction is also used for localizing the name & description.
<faction key> = {

	# Dynamic name, will look for the identifier of the type (faction_name) if doesn't exist or if it's empty.
	name = [loc_key|dynamic descriotion]

	# Dynamic description, will look for the identifier of the type + _desc (faction_name_desc) if doesn't exist or if it's empty.
	description = [loc_key|dynamic description]

	# Dynamic description of the effect, used to summarize faction goals
	short_effect_desc = [loc_key|dynamic description]

	## Faction with claimant for a title
	#
	# Faction needs a character and a title to properly function.
	# Used for claimant factions where a character and a title must be provided by the player.
	#
	# Default: no
	#
	claimant = <yes/no>

	## Character interaction creates the faction (optional)
	#
	# Used for claimant factions where a character and a title must be provided by the player.
	#
	# Enabling this will replace the original behaviour of the faction buttons in the faction window.
	# Instead of starting a faction it will pop up a window for a character interaction.
	# The character interaction is then responsible for starting the faction.
	#
	character_interaction = <character interaction key>

	## Effect fired when a faction of this type is created.
	#
	# Scopes:
	#  - root: the faction
	#
	on_creation = <effets>

	## Effect fired when a faction of this type is destroyed.
	#
	# Scopes:
	#  - root: the faction
	#
	on_destroy = <effects>

	## Effect that will launch when the demand triggers.
	#
	# Scopes:
	#  - root: the faction
	#
	demand = <effects>

	# Effect that will launch every NDefines::NFaction::UPDATE_INTERVAL_DAYS.
	#
	# Scopes:
	#  - root: the faction
	#
	update_effect = <effects>

	## Effect that will launch when the faction declares war.
	#
	# Scopes:
	#  - root: the faction
	#
	on_declaration = <effects>

	## Effect that will launch when a character leaves the faction.
	#
	# Scopes:
	#  - root: the faction
	#  - faction_member: The leaving faction member
	#
	character_leaves = <effects>

	## Effect that will launch when the leader leaves the faction.
	#
	# Scopes:
	#  - root: the faction
	#  - faction_member: The leaving faction member
	#
	leader_leaves = <effects>

	## Does AI character want to join?
	#
	# MTTH that calculates the the score to join an active faction of this type.
	#
	# Scopes:
	#  - root: character that might join.
	#  - faction: target is the active faction.
	#
	# Note that the score is then modified by code to weigh in the effects of Boldness/Dread, Energy and Rationality.
	# See NFaction AI defines.
	#
	ai_join_score =  <mtth>

	# MTTH that calculates the the score to create an active faction of this type.
	#
	# Uses the SCOPE_CHARACTER of the character that tries to create it.
	#  - target: target is the targeted character.
	#
	# The claimant faction has two additional scopes:
	#  - claimant: (who is the potential claimant)
	#  - title: (the title to claim for).
	#
	# Note that the score is then modified by code to weigh in the effects of Boldness/Dread, Energy and Rationality. See NFaction AI defines.
	ai_create_score = <mtth>

	## MTTH that calculates the score to join an active faction of this type.
	#
	# Scopes:
	#  - root: the title that tries to join
	#  - faction: target is the active faction.
	#
	county_join_score =  <mtth>

	## MTTH that calculates the score to create an active faction of this type.
	#
	# Scopes:
	#  - root: the title that tries to create it.
	#  - target: the targeted character.
	#
	#  If the score is >= NDefines::NFaction::COUNTY_CREATE_MIN_SCORE, and it gets a random chance 0-100 on a monthly update.
	#
	county_create_score = <mtth>

	## Script value defining the absolute power of a single county member.
	#
	# The final power is calculated as ratio of this power and the target's military strength.
	#
	county_power = <script value>

	## MTTH that calculates the score to trigger the demand effect of active faction of this type.
	#
	# Scope:
	#  - root: the faction
	#
	# Checked once a month
	#
	ai_demand_chance = <mtth>

	## MTTH that calculates the discontent progress change of the active faction.
	#
	# Scope:
	#  - root: the faction
	#
	discontent_progress = <mtth>

	## MTTH for power threshold at which the discontent starts ticking up.
	#
	# Scopes:
	#  - root: the faction
	#
	# NFaction::DEFAULT_POWER_THRESHOLD define if not set
	#
	power_threshold = <mtth>

	## Trigger to check if the faction is still valid.
	#
	# Scopes:
	#  - root: the faction
	#
	is_valid = <triggers>

	## Trigger to check if the faction type should be shown to the player
	#
	# Scopes:
	#  - root: the player
	#
	is_shown = <triggers>

	## Trigger to check if a character is still valid to be part of the faction.
	#
	# Scopes:
	#  - root: the member character
	#  - faction: the faction
	#
	is_character_valid = <triggers>

	## Trigger to check if a county is still valid to be part of the faction.
	#
	# Scopes:
	#  - root: the county county
	#  - faction: the active faction
	#
	is_county_valid = <triggers>

	## Trigger to check if a character can join the active faction.
	#
	# Scopes:
	#  - root: the character that tries to join.
	#  - faction: the active faction.
	#
	# The is_character_valid check ais automatically included, so its triggers should not be repeated here.
	#
	can_character_join = <triggers>

	## Trigger to check if a character can create the active faction.
	#
	# Scopes:
	#  - root: the character that tries to create.
	#  - SCOPE:target target is target character of the faction.
	#
	can_character_create = <triggers>

	## Can faction be created by a player?
	#
	# Trigger to check if the button to create a faction will be enabled.
	#
	# Scopes:
	#  - root: the character that might create a faction of this type
	#  - target: target character of the faction
	#
	# Falls back to the regular can_character_create triggers if left empty.
	#
	can_character_create_ui = <triggers> # ???

	## Trigger to check if a member character can become the leader of the faction.
	#
	# Scopes:
	#  - root: the character attempting to become leader
	#  - faction: the faction
	#
	can_character_become_leader = <triggers>

	## Trigger to check if a title can join the active faction
	#
	# Scopes:
	#  - root: landed title that tries to join
	#  - faction: the active faction.
	#
	# Note: is_county_valid is automatically included and its triggers should not be repeated here.
	#
	can_county_join = <triggers>

	# Trigger to check if a title can create the active faction.
	#
	# Scopes:
	#  - root: the title that tries to create this faction
	#  - target: character that the faction is intended to target
	#
	can_county_create = <triggers>

	## Are characters allowed to create this at all?
	#
	# Default: yes
	#
	character_allow_create = <yes/no>

	## Are characters allowed to join all?
	#
	# Default: yes
	#
	character_allow_join = <yes/no>

	## Is county allowed to create this faction type?
	#
	# Default: yes
	#
	county_allow_create = <yes>

	## Is a county allow joint this faction type?
	#
	# Default: yes
	#
	county_allow_join = <yes/no>

	## Is the leader allowed to leave the faction?
	#
	# (used for faction that create leaders)
	#
	# Default: yes
	#
	leaders_allowed_to_leave = <yes/no>

	## Are player characters allowed to join?
	#
	# When not allowed the join button for this faction type will be hidden for players.
	#
	# Default: yes
	#
	player_can_join = <yes/no>

	## Can the target have more of one faction of this type targeting them?
	#
	# Default: no
	#
	multiple_targeting = <yes/no>

	# The casus belly to be executed for the war
	casus_belli = <casus belly key>

	# How the special character of this faction will be called
	special_character_title = <loc key>

	## Will this faction ignore the faction soft block?
	#
	# Default: no
	#
	ignore_soft_block = <yes/no>

	## Inherit membership?
	#
	# Heirs that changed liege or tier as a result of succession will inherit faction membership.
	#
	# Default: yes
	#
	inherit_membership = <yes/no>

	## Requires at least one county member, otherwise it will be destroyed.
	#
	# Default: no
	#
	requires_county = <yes/no>

	## Requires at least one character member, otherwise it will be destroyed.
	#
	# Default: yes
	#
	requires_character = <yes/no>

	## Requires a valid faction leader, otherwise it will be destroyed.
	#
	# Default: no
	#
	requires_leader = <yes/no>

	## Will counties switch factions?
	#
	# Make counties leave this faction if there's a better factions available for them to join or create
	#
	# Default: no
	#
	county_can_switch_to_other_faction = <yes/no>

	# Order to sort factions in the UI. Lower value => higher in list.
	#
	# Default: 0
	#
	sort_order = 1..n

	## Should the special title be shown in the interface or not?
	#
	# Default: no
	#
	show_special_title = <yes/no>
}

== Event targets ==
[SCOPE_FACTION.faction_target]					- Links to the character targeting the faction
[SCOPE_FACTION.faction_leader]					- Links to the character leading the faction
[SCOPE_FACTION.faction_war]						- Links to the faction war
[SCOPE_FACTION.special_character]				- Links to the special character
[SCOPE_FACTION.special_title]					- Links to the special title
[SCOPE_CHARACTER.leading_faction] 				- Links to the faction is leading. Null faction if it's not leading any faction
[SCOPE_CHARACTER.joined_faction]  				- Links to the faction the character is in. Null faction if it's not in any faction

== Related loc/UI functions ==
[Faction.GetName] 					- Gets the name of the faction type. E.G., "Independent Faction"
[Faction.GetDescription]			- Gets the description of the faction type
[Faction.GetDiscontent] 			- Gets the current dicontent of the faction
[Faction.IsAtWar]					- Gets if the faction is currently at war
[Faction.GetPower] 					- Gets tthe current power of the faction
[Faction.GetTarget] 				- Gets the target character of the faction
[Faction.GetLeader] 				- Gets the leader of the faction
[Faction.GetSpecialCharacter] 		- Gets the special character of the faction
[Faction.GetSpecialTitle] 			- Gets the special title of the faction
[Faction.GetSpecialCharacterTitle] 	- Gets the title for the faction's special character eg: Claimant, Leader etc.
[Faction.HasSpecialCharacter]		- Checks if there is a special character of the faction
[Faction.HasSpecialTitle] 			- Checks if there is a special title of the faction

== Related lists ==
[targeting_faction]			- List of the factions targeting the SCOPE_CHARCTER
[faction_member]			- List of the character members in the SCOPE_FACTION
[faction_county_member]		- List of the county members in the SCOPE_FACTION
