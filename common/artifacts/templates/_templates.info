# The optional scripted base component of an artifact containing triggers and effects that cannot be read during artifact creation.
# Determines for example if a given character can wield an artifact or get its full benefits.
# Root scope is character for all triggers, but the artifact can be accessed via scope:artifact

example_template = {

	# can this character equip this artifact?
	can_equip = {
		always = yes
	}

	# can this character benefit from the full modifiers of the artifact?
	can_benefit = {
		is_christian_trigger = yes
	}
	
	# can this character reforge this artifact (turn this artifact into another)
	can_reforge = {
		is_christian_trigger = yes
	}

	# can this character repair this artifact (restore its durability)
	can_repair = {
		always = no
	}

	# if a given character does not pass the "can_benefit" trigger then this modifier will be applied instead.
	fallback = {
		monthly_prestige = 0.3
	}

	# Adds the final value to the AI equipping score, note the can_benefit takes precedence over the score when AI equipping
	# artifact_ai_will_equip_score in game/common/scripted_values/00_artifact_values.txt also effect the final score
	ai_score = {
		value = 100
	}

	# Artifacts with this templates show as unique, default = no 
	unique = yes
}
