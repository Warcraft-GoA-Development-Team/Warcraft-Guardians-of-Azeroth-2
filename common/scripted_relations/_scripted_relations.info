This documentation is rather scant. Sorry.

== Structure ==
my_relation = {
	opinion = 42			# Opinion the owner of the relation has towards the target
	special_guest = yes		# If the relation target is in the same court, this will be shown specially in the court list (e.g. "Harold's Ward"); default: no
	title_grant_target = yes 	# They might get given titles if they're unlanded and their liege or above has this relation towards them
	relation_aliases = { friend } # If you for example use random_relation_friend other relations specifying friend as an alias will also be a valid relation.
	hidden = yes			# Relation is not shown to the player

	# Flags that can be used with this relation, a maximum of 32 are allowed
	flags = {
		flag_1 flag_2 flag_3
	}
}


== On-actions ==
Each scripted relation has several associated on-actions:
- root = the relation owner ("source" of the relation)
- scope:target = the relation target
on_set_relation_x = { }		# Has just been added. Not triggered if the relation is added because it is corresponding to another relation.
on_remove_relation_x = { }	# Has just been removed & before the corresponding relation is removed
on_death_relation_x = { }	# When the owner of the relation is about to die

These will fire when the relation is set or removed via script.

For example, you could do:
on_set_relation_lover = {
	events = {
		debug.0001
	}
}
The initiator is ROOT, the other character is scope:target.
For two-way relations, the on-action only fires on the initiator. Including if the corresponding relation is a different one (E.G., mentor vs. student)


== Opinion Modifier ==

opinion = 30

The impact the relation gives on the owning character's opinion of the relation target.


== Modifiers ==

modifier = {
	monthly_prestige = 1
}

A modifier applied to all characters with the relation. (This means that applying it two a two-sided relation will give both characters the modifier.)

This cannot use any references to modifiers generated from other database objects, such as seduce_scheme_phase_duration_mult (from schemes) or monthly_diplomacy_lifestyle_xp_gain_mult (from lifestyles).
Generic modifiers like monthly_lifestyle_xp_gain_mult (doesn't reference a specific lifestyle) are allowed.

== Fertility ==

A multiplier against their fertility, used in place of the PRIMARY_SPOUSE_FERTILITY_MULTIPLIER etc defines

fertility = 1.25

== Flags ==

Relations support up to 32 simple flags. They have to be defined in the relation itself and their order does matter across save games. Note that these are effectively simple bool checks, and cannot be timed.

In script:

add_relation_flag = {
	flag = first_flag
	target = scope:target
	relation = relation_type
}

remove_relation_flag follows the same syntax.

== Reasons ==
set_relation_xxx = target # will add the relation with no reason

set_relation_xxx = { target = character reason = key } # add relation with reason as key, if there is a corresponding relation then key_corresponding can be used to give that corresponding relaiton a different reason key

set_relation_xxx = { target = character reason = key copy_reason = relation } # add relation, copy the reason key from another relation as an additional reason here, good for promoting from rival to nemesis and keeping the inital reason displayed
