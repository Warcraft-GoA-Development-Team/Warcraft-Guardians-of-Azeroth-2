=== Lease Contracts ===

Titles can be leased out by the holder to another character. (Only non-capital baronies, and the holder must be above baron rank.)
Income and levies from the leased holdings can be splt between the ruler, lessee and (for hierarchical leases) a "lease liege".

== Lease Hierarchies ==

Built-in lease types can be used to automatically lease out holdings according to a specific hierarchy.
In that case there is a lease vassal hierarchy in parallel to the normal vassal hierarchy:

Emperor -- Emperor's lessee
|		  |
King ----- King's lessee
|		  |
Duke ----- Duke's lessee
|		  |
Count ---- Count's lessee
|
Baron

Rulers can be excluded from participating in the amtomatic lease with a trigger, e.g. only rulers with a specific faith property might take part in a theocratic lease.
And rulers in the vassal hierarchy can be skipped using another trigger. E.g. for the theocratic lease the ruler and vassal must have the same faith. The skipped rulers will be part of their own hierarchy with matching rulers in the same realm.
The lessee must be a direct vassal of the ruler. If the lessee is missing for a specific ruler the ruler is also skipped in the hierarchy.
Titles in the ruler's domain that match a trigger will be automatically leased to the lessee.

== Structure ==

theocracy_lease = {
	# Definition for automatic lease hierarchy. Required for some built-in lease contracts, not supported for the others.
	hierarchy = {
		ruler_valid = { <triggers> }			# Does this ruler use the lease? root: character; default always = yes
		lessee = <event target>					# The character leasing the titles from the ruler. root: character. Must be unique for a given ruler, and their liege must be the ruler

		# Is this ruler valid as a liege or vassal to the scope:target? If not, this ruler is skipped in the lease hierarchy and starts their own hierarchy.
		# root and scope:target are characters; default always = yes
		liege_or_vassal_valid = { <triggers> }

		barony_valid = { <triggers> }			# Is this barony title automatically leased out? root: title default always = yes
	}

	# List of holding types that will not generate a wrong holding type penalty for the lessee
	valid_holdings = { church_holding }

	# Used in the UI to show why the ruler receives benefits from the leased titles. Make sure it corresponds to the values used below.
	# Don't set if you don't use the same opinion value between levies and taxes or the conditions are different, so that the tooltip is not shown.
	ruler_share_min_opinion_from_lessee = 42

	# Used in the UI to show if a ruler should recieve the benefits by having a hook even if they do not meet the opinion value. Make sure it gets used to apply based on the values below.
	hook_strength_max_opinion = none/any/strong

	# How income from leased holdings is split. By default everything goes to the lessee.
	tax = {
		lease_liege = 0..100		# Share that goes to the lease liege (if exists). Requires hirarchy definition. Default: 0

		# Anything not going to the liege can be split between ruler and lessee. By default everything goes to the lessee.
		rest = {
			max = 0..100				# Used in the UI to show maximum possible split share that goes to the to the ruler
			weight = {} 				# Share that goes to the left hand side target. MTTH. Result should be between 0 and 100.
			beneficiary = ruler/lessee 	# Who gets the ratio calculated in weight
			rest = ruler/lessee			# What is left goes to the right hand side target
		}

		# Alternative syntax giving the rest to one character only:
		#rest = ruler/lessee
	}

	# How levies from leased holdings are assigned. By default everything goes to the lessee.
	levy = { ... }	# See tax for syntax
	# Note: Levies can only go to one character on each level. This means levies cannot be assigned in part to the ruler and in part to the lessee
	# because they are considered to be on the same level. So you can use only 0 or 100 when splitting between ruler and lessee.
}
