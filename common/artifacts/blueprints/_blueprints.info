# Determines what ( if anything ) an artifact of a certain type can be reforged into
# The below example would turn a spear into a court artifact mounted on the wall.

example = {
	# for an artifact to be used with this blueprint it needs to match these in_ types!
	in_type = spear # artifact type, determines slot and category ( inventory/court )
	in_visuals = spear # artifact visual type, determines 3d assets, icons etc.

	# these out_ types determine the artifacts looks and usage post-reforge
	out_type = wall_big # artifact type
	out_visuals = spear # artifact visual type

	# an array of modifier types that will not be allowed to persist on the artifact post-reforge
	disallowed_modifiers = {
		prowess
	}

	# a nested array of static modifiers that will be used instead of any modifier containing the above disallowed modifiers post-reforge
	# the system will pick a number of random modifiers ( no duplicates ) from the corresponding rarity list
	replacement_modifiers = {
		common = {
			artifact_monthly_piety_1_modifier
		}
		masterwork = {
			artifact_monthly_piety_2_modifier
		}
		famed = {
			artifact_monthly_piety_3_modifier
		}
		illustrious = {
			artifact_monthly_piety_4_modifier
		}
	}

	# changes the template of the artifact to the specified scripted template. Templates are specified in artifacts/templates/
	template = artifact_template_key
}
