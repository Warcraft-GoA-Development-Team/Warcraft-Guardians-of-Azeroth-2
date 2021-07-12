== Structure ==

secret_key = {
	# Optional free category string.
	# Used to assign category icons in gfx/interface/icons/secret_categories/<category>.dds
	# and the category name "secret_category_<category>"
	# Default: empty
	category = "..."

	# Secrets disappear when they become invalid, e.g. a homosexual secret is no longer valid when the owner gets the sodomite trait.
	# scope:secret_owner -> the one who the secret is about
	# scope:secret_target -> optional character related to the secret, e.g. the lover in a lover secret
	is_valid = {}

	# Is the secret chunned/criminal by another character?
	# Scopes are the same as for is_valid, plus:
	# scope:target -> character to check whether they view the secret as shunned/criminal
	is_shunned = {}
	is_criminal = {}

	# Effect executed when another character discovers the secret
	# Scopes are the same as for is_valid, plus:
	# root -> the secret
	# scope:discoverer -> the character who discovered the secret
	on_discover = {}

	# Effect executed when a character exposes the secret
	# Scopes are the same as for is_valid, plus:
	# root -> the secret
	# scope:secret_exposer
	on_expose = {}

	# Effect executed when the owner of the secret dies.
	# Note that the owner is now already set to the next participant of the secret.
	# If there is no alive owner after this effect, the secret will be removed.
	# Scopes are the same as for is_valid, plus:
	# root -> the secret
	on_owner_death = {}
}
