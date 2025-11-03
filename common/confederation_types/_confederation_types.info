### Confederation types ####
#
# This file contains the definitions of confederation types.
#
<key> = {

	# Is this confederation based on DynastyHouse instead of Characters?
	house_based_confederation = no

	## The base monthly change for the cohesion value
	#
	# TO BE FILLED IN
	#
	# Scope:
	#  root - The confederation
	#  bloc - The bloc being evaluated
	#
	# TO BE FILLED IN
	#
	cohesion_base_change_monthly = <scripted value>

	## How large should the impact of a single house be on a confederation/bloc?
	#
	# For each house in a bloc applied once for every house relation with that of another house in the bloc.
	# Sum of all these contributions is the final contribution to cohesion for that bloc.
	#
	# Scope:
	#  root - The confederation
	#  house - The house being evaluated
	#
	# The final contribution of the house will be added up alongside the bonus for the
	# house relation provided in cohesion_contribution.
	#
	cohesion_base_change_per_house_monthly = <scripted value>

	## How large should the impact of a single house relation be on a confederation/bloc?
	#
	# For each house in a bloc applied once for every house relation with that of another house in the bloc.
	# Sum of all these contributions is the final contribution to cohesion for that bloc.
	#
	# Scope:
	#  root - The confederation
	#  base_value - The value from cohesion_contribution on the House Relation level
	#  house - The house being evaluated
	#  house_relation - The relation between this house and the other one
	#  other_house - The other house of the relation
	#  num_relations - Total number of relations to the other houses in the same bloc
	#
	# The final contribution of the house will then also be multiplied by either
	# COHESION_FROM_LEADER_HOUSE_RELATION_MULT or COHESION_FROM_MEMBER_HOUSE_RELATION_MULT
	# depending on if the house being evaluated is, or isn't the leading house.
	#
	cohesion_contribution = <scripted value>

	## At what point do cohesion growth start slowing down?
	#
	# Soft limit for bloc cohesion which, once gone over, will reduce gained additional monthly cohesion
	# causing diminishing returns.
	#
	# Every time coheion is gained a fraction of the whatever is above soft cap is deducted from the total cohesion.
	# The fraction of reduction is  a number between 0 and 0 defined by `COHESION_SOFT_CAP_TAX`.
	#
	# Scope:
	#  root - The confederation
	#
	# Example:
	# Given current cohesion is 40,  soft cap is 50, and fraction is 25%.
	# When bloc gains 20 it will would 50 over by 10 if unhindered.
	# Then the actual all gain becomes only 17.5, and cohesion stops 57.5.
	# This is because 2.5 (=10 o.25) of the 10 gained that went over soft cap are not aded to cohesion.
	#
	# Think of it like a rubber band. While still loose it applies no force, but once it starts to stretch
	# it will apply force in the opposite direction relative to how long it has been stretched.
	# A high tax (close to 1) gives a sharp slope of d returns, while a low value gives a slow turn down.
	# None of them will however make the value go back under the soft cap (except for values >1.0).
	#
	cohesion_soft_cap = <scripted value>

	## Cohesion level
	#
	# Various bonuses awarded to confederation/bloc members once cohesion is equal or greater to some value.
	# The highest level is used. If cohesion is lower than the first level, then no bonuses are provided.
	#
	cohesion_level = {
		### Cohesion threshold
		#
		# Minimum amount of confederation cohesion required to get this level of bonuses.
		#
		cohesion_threshold = <num>
	}

	## Is this confederation still valid, or should it dissolve?
	#
	# When a confederation fails the following check - we destroy the Confederation.
	# There is also an effect when this is being done
	#
	# Scope:
	#  root - The confederation
	is_valid_confederation = <trigger>
	on_confederation_destroyed = <effect>

	## Modifiers applied to various members of houses in a bloc (house based confederation)
	#
	# Houses inside a bloc/confederation come in three categories:
	#  - The *leading* house is the house that leads the confederation,
	#    and it's aspiration determines the type of confederation
	#  - An *aligned* house has the same aspiration as the leader, and is rewarded for that.
	#  - A *divergent* house has a different aspiration as the leader, and is punished for that.
	#
	# Ideally you'd want to belong to a confederation stat shares your aspiration.
	#
	# On top of these category specific modifiers there are also modifiers that apply to anyone in a house.
	#
	leading_house_head = <modifier>
	leading_house_member = <modifier>
	aligned_house_head = <modifier>
	aligned_house_member = <modifier>
	divergent_house_head = <modifier>
	divergent_house_member = <modifier>
	any_member_house_head = <modifier>
	any_member_house_member = <modifier>

	## Member character
	#
	# Determine if a character is a valid member.
	# Fire effects when they when they join or leave the confederation.
	#
	# Characters can either be individually added to the confederation or be added indirectly by being a member of a house.
	# these triggers and scripts manage both cases.
	#
	# Scope:
	#  root - The confederation
	#  character - The character who can be expected to be a living ruler
	#  house (conditional) - The house that the character belongs to which causes the character to be indirectly added.
	is_valid_member_character = <trigger>
	on_member_character_joined = <effect>
	on_member_character_left = <effect>


	## Member house
	#
	# Determine if a house is a valid member.
	# Fire effects when they when they join or leave the confederation.
	#
	# Scope:
	#  root - The confederation
	#  house - The house
	is_valid_member_house = <trigger>
	on_member_house_joined = <effect>
	on_member_house_left = <effect>
}
