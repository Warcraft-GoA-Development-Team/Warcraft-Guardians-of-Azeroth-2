Scripted modifiers work like scripted effects and triggers.

Can be invoked without parameters using "name = yes", or can take any number of parameters.

== Example modifier ==
example_modifier = {
	modifier = {
		add = { value = 10 multiply = $SCALE$ }
		$CHARACTER_1$ = {
			has_trait = ambitious
		}
	}
	opinion_modifier = {
		target = $CHARACTER_2$
		who = $CHARACTER_1$
		multiplier = { value = 0.25 multiply = $SCALE$ }
	}
	compare_modifier = {
		target = $CHARACTER_1$
		value = stress
		multiplier = $SCALE$
	}
}

== Example invocation ==
random_list = {
	1 = {
		example_modifier = {
			CHARACTER_1 = root
			CHARACTER_2 = root
			SCALE = 0.1
		}
	}
}
