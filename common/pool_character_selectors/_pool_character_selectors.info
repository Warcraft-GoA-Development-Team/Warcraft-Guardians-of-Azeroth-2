== Structure ==

name_of_selector = {
	
	valid_character = { trigger } # which pool characters are valid to be considered
	character_score = { mtth } # score for random selection of valid pool characters
	config = {
		background = character_background # also used to validate pool characters (ie no need to check for trait that will be required by the background)
		age = { min max } # age span for randomization
	}
	
	selection_count = x # starting from the highest scoring candidates, the number of candidates that will be considered for random scoring (not scripting or setting to negative will use all valid =1 will select the highest scoring always (random tiebreaker )
}

Scopes that are always set:
scope:base # the character that is set as the base character, usually the council owner or the predecessor

For the following hard-coded generators we also have additional scopes.

auto_generated_baron additional scopes:
scope:province # the province for the barony title that needs a generated baron
