name_of_death_reason = {
	public_knowledge = yes/no		# If set to yes, everybody knows the killer. Default = no
	icon = ....dds					# An icon that should be used for this death reason. The directory is set in the DEATH_REASON_ICON_PATH define. DEFAULT_DEATH_REASON_ICON will be used if not specified.
	natural_death_trigger = ...		# A trigger in the dying character's scope saying that this is a valid reason for the natural death of the character.
	priority = X					# When picking a natural death reason for a character, the reason with highest priority will be picked (if it passes the trigger). Default = 0
	default = yes/no				# When no natural death reasons can be picked, one of the reasons marked as default will be picked randomly. Default = no

	use_equipped_artifact_in_slot = slot_type # Some artifact slot which if filled and this death reason used, that artifact will be said to have been used to kill someone

	# What epidemic type is this death reason tied to
	# Will be considered if they have the epidemic's disease trait
	# If they have the trait from an ongoing epidemic then their death will be added to that epidemic's total deaths, if the epidemic is over or the trait
	# was added by effect then it will not add them
	epidemic = <epidemic_key>
}
