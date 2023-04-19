# Memory type name
memory_key = {
	categories = { testing debug } # Categories, arbitrary strings, used to provide groupings of related types

	# Dynamic description for this memory
	# root = memory
	# scope:owner = memory owner
	# Participants saved with their key from the creation effect
	description = {
		first_valid = {}
		random_valid = {}
		etc.
	}

	# Description for a second person perspective
	second_perspective_description = {
		first_valid = {}
		random_valid = {}
		etc.
	}

	# Description for a third person perspective
	third_perspective_description = {
		first_valid = {}
		random_valid = {}
		etc.
	}

	# Expected participants when creating a memory of this type
	# Note: Memories also support variables, but you should much prefer using participant characters over saving character variables as participants
	# are faster to use and make sure the referenced participating character will not be pruned from save games. Use variables for other references like titles
	# or provinces etc.
	participants = {
		attacker defender
	}

	# Default duration for memory, script value
	duration = {
		years = 1
	}
}

### Localization
GetName returns memory_key
GetDescription returns the description

### Effects

# Scope type: character
# Creates a memory, saves it as scope:new_memory
# Participant name tags must only appear once, that is not saving multiple attack and defender
create_character_memory = {
	type = test_memory

	participants = {
		attacker = root.father
		defender = root.mother
	}
}

destroy_character_memory = scope:new_memory

### Triggers
has_memory_type = memory_type
has_memory_category = category
has_memory_participant = some_character

### Lists
# Memory to character list
any_memory_participant = {
	
}

# Character to memory list
random_memory = {
	random_memory_participant = {

	}
}

### Links
# Memory to character link
scope:memory.memory_owner

# Participant, takes in tag name, if not present in memory will log an error
scope:memory.memory_participant:attacker
