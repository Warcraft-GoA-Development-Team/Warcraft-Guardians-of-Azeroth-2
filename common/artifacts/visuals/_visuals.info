# Determines the visuals of an artifact and ties together 2d and 3d visuals
# Picks a random valid one based on the triggers, passes in the scopes from the creation/reforge like the text does

example = {
	icon = "icon_name.dds"
	asset = "asset_name"

	# optional field with no gameplay effect. Only needed for automatic test artifact generation
	default_type = type_key

	icon = {
		trigger = {
			<trigger>
			#root scope is the owner
			#scope:artifact is the artifact being made
			#scope:artifact.creator is how to access the creator when different from the owner
		}
		reference = "icon_name.dds"
	}
	asset = {
		trigger = {
			<trigger>
		}
		reference = "asset_name"
	}
}
