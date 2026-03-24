- _category = { ... } creates a new group with name category ( lead with '_' to create a group )
- first and third indicates first person or third person, default is no or global pronoun
- past indicates past tense, default is future/present
- neg indicates that this is used for negative output values, ie "gain x gold" versus "lose x gold"
- the value given to the localization of a neg version will always be positive

# Default format
You do not need to define an effect_localization entry, the system will look at localization keys like this:
(only within quotes is what is in loc)

<effect_name>_first         # "I gain 123 gold"
<effect_name>_first_past    # "I gained 123 gold"
<effect_name>_third         # "King John gains 123 gold"
<effect_name>_third_past    # "King John gained 123 gold"
<effect_name>_global 		# King John: "Gains 123 gold"
<effect_name>_global_past 	# King John: "Gained 123 gold"

If you want to provide a custom negation localization, add a '_neg' postfix - primarily for Value changing effects.

<effect_name>_global_neg    # King John: "Lost 123 gold"


