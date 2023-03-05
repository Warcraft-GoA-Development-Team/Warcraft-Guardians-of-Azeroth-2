When making a new culture, its name will be picked from here if possible.

The logic works like this:
1. Find an unused name from here if there is one whose trigger we meet
2. Go through HYBRID_NAME_FORMAT_<number> until we find one that's unused
3. Use the last HYBRID_NAME_FORMAT_<number> if we were unable to find anything
For divergence, the format is DIVERGE_NAME_FORMAT_<number> instead.
There can be any number of name formats as long as there's no gaps.

Checking if a name is in used is purely based o nthe name field; collective noun and prefix we do not check the uniqueness of.

== structure ==
key = {
	name = dynamic_desc # Optional. Defaults to <key>_name
	collective_noun = dynamic_desc # Optional. Defaults to <key>_collective_noun
	prefix = dynamic_desc # Optional. Defaults to <key>_trigger

	trigger = {
		# root: Character creating the culture
		# scope:culture: Their culture
		# scope:other_culture: Only available for hybridization. The other culture involved
	}

	hybrid = yes # Is this for hybridization? Defaults to no
}
