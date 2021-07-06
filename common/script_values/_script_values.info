Script values are simple or complex values that can be referenced virtually anywhere in script that takes a number (and in some cases true/false values).

They come in two main variants; simple static values, and formulas.

== Static values ==
Static values are defined like this:
name_of_scripted_value = value (E.G., "minor_stress_gain = 10")

They're referenced in script by their name:
add_stress = minor_stress_gain

== Formulas ==
For more complex values, it is possible to define mathematical formulas. These allow you to use everything available in the scope you're currently in.
Be careful with these, as they have to be calculated every single time they're evaluated. Complex formulas can be performance intensive.
Formulas do not work for true/false values.

A formula is declared using curly brackets, and follow this format:

name_of_scripted_value = {
	# Mathematical operations
	add = number/scripted value/scope.something
	subtract = ...
	multiply = ...
	divide = ... # Be careful not to divide by 0
	modulo = ...
	
	value = ... # Sets the value to this number
	
	max = ... # Sets the value to this number if it is currently higher. E.G., "max = 10" would cause the number 15 to become 10
	min = ... # Sets the value to this number if it is currently lower
	
	round = yes # Rounds to nearest whole number
	ceiling = yes # Rounds up (towards positive infinity)
	floor = yes # Rounds down (towards negative infinity)
	
	if = { # These operations are executed if the limit is met. You can also put "if" inside an "if"
		limit = { some conditions }
		add = 5
		divide = ...
		...
	}
	else_if = { # If the "if" above is not met, these operations are executed, as long as the limit is met. You can put several "else_if" in a row
		limit = { some conditions }
		operations...
	}
	else = { # If the "if" or "else_if" above is not met, these operations are executed
		operations...
	}
	
	fixed_range = { # Gives a random fixed-point number in the range (E.G., 1.242)
		min = ... script value
		max = ...
	}
	
	integer_range = { # Gives a random fixed-point number in the range (E.G., 1)
		min = ...
		max = ...
	}
}

=== Execution order ===
Operations are executed in the order defined.
Example:
	value = {
		add = 5
		multiply = 4
		max = 10
		add = 5
	}
Would result in "15", since "max = 10" would be applied before the last "add = 5"

=== Inlining ===
Formulas can be written inline wherever scripted values work. So if a formula is only to be used once, there's no need to name it and have it in the scriptvalues folder.

Example:
	add_gold = {
		value = gold
		multiply = { # Yes, you can even inline them in the mathematical operators
			value = 1
			multiply = 0.5
		}
	}
	
=== Chaining ===
You can reference named script formulas using scope chaining. For example, if you were to define this formula:
	example_age = {
		value = age
	}
Then the following would work:
	add_gold = {
		value = mother.example_age
	}

== Ranges ==
Script values can also define ranges.
E.G., add_gold = { 1 5 } will add 1 to 5 gold.
add_gold = { named_value another_named_value } will resolve the named values (including formulas).
Note that you can't inline formulas within a range. E.G., you cannot do add_gold = { { value = 1 add = 2 } some_named_value }. If you need that, use integer_range or fixed_range from the script math system.

== Lists ==
Script values support lists.
E.G., add_gold = { every_child = { add = 1 } } will add as much gold as you have children.
All lists should work, including those defined in script.

Ordered lists also work. E.G.,
add_gold = {
	ordered_child = {
		order_by = age
		max = 3
		add = age
	}
}

== Scoping ==
You can change scope within script values just as you can in regular script.
Example:
	add_gold = {
		father = {
			any_child = { add = 1 }
		}
	}
This would add as much gold as your father has children.	
