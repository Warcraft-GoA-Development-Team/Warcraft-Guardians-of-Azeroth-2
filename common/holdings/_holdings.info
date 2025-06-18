== Structure ==

name_of_the_holding = {

	### brief: primary_building ( key )
	# The primary building for this holding
	# (will be built when creating a holding of this type)
	#
	primary_building = city_01
	
	### brief: buildings ( keys, optional )
	# First levels of all buildings buildable in the holding
	# (doesn't include the primary building)
	#
	buildings = {
		city_market_01
		common_shipyard_01
		...
	}
	
	### brief: can_be_inherited ( bool, optional)
	# Can a barony with this holding be inherited?
	# Default: yes
	#
	can_be_inherited = yes/no

	### brief: counts_toward_domain_limit_if_disabled ( bool, optional)
	# Does a barony with this holding type count toward a ruler's domain
	# limit if the holding is disabled?
	# Default: yes
	#
	counts_toward_domain_limit_if_disabled = yes/no

	### brief: required_heir_government_types ( array of database keys, optional )
	# Which government types are required to inherit a county title with
	# this holding built in the capital province when succession occurs?
	# If generating a character for county title of this province during succession,
	# the first government type in the list will be used. 
	# Keys are mapped to the government types database: common/governments
	# Default: none
	#
	required_heir_government_types = {
		nomad_government
		...
	}

	### brief: parameters ( keys, optional )
	# An arbitrary list of parameter keys which can be checked with
	# the has_holding_parameter trigger
	# Default: none
	#
	parameters = {
		no_buildings
		...
	}
}

== Modifiers ==
The following modifiers are automatically generated for all holding types:

* <holding_type>_build_speed (example: church_holding_build_speed)
* <holding_type>_build_gold_cost
* <holding_type>_build_piety_cost
* <holding_type>_build_prestige_cost
* <holding_type>_holding_build_speed
* <holding_type>_holding_build_gold_cost
* <holding_type>_holding_build_piety_cost
* <holding_type>_holding_build_prestige_cost
These affect building buildings within such a holding or the holdings themselves.

These work everywhere the more generic version works. E.G., church_holding_build_speed will work everywhere build_speed does.
