At game start, the religions and faiths defined in this folder will exist.

== structure ==
religion_name = {
	family = family_name	# What religion family the religion belongs to
	graphical_faith = catholic_gfx # All faiths in this religion default to this 3D model (currently used for temple assets). Order of precedence is the lowest level scripted in: faith > religion > family.
	piety_icon_group = christian	# All faiths in this religion default to this set of piety icons. Order of precedence is the lowest level scripted in: faith > religion > family.
	doctrine_background_icon = 	# All faiths in this religion default to this doctrine background icon. Order of precedence is the lowest level scripted in: faith > religion > family.
	pagan_roots = yes			# if yes, then faiths without the unreformed doctrine are considered reformed by the interface
	doctrine = name
	doctrine = another_name # Doctrines defined in a religion will be applied to all faiths within it. This is only at game start; it is purely for script convenience, and would be equivalent to putting the doctrine in all the faiths. It can be overridden by putting a different doctrine in the group in the specific faith. Note that doctrines that allow more than one pick can *not* be defined on a religion level, as there's no obvious override system that would work then

	doctrine_selection_pair = { # Adds a doctrine if the flag is present
		requires_dlc_flag = <dlc_flag> # Flag that will be evaluated
		doctrine = name # Name of the doctrine that will be added if the dlc flag is present
		fallback_doctrine = name # Optional. If the flag isn't present and the fallback_doctrine is defined, this doctrine will be added instead
	}
	# Doctrines cannot be defined after the faiths section
	
	traits = {
		virtues = { brave generous }	# List traits that are virtues for all followers. Trait groups also work. If more than one trait in a group is defined (or the group itself), only the first will be shown in the UI
		sins = { ... }					#					  (sins)
		# Virtues and sins give an opinion bonus/penalty (see VIRTUOUS_TRAIT and SINFUL_TRAIT defines). For that it is the "viewer's" faith that matters.
		# E.g. if generous is a christian virtue, all christian characters will think more highly of all others with that trait, even if the others are not christian.
		# Holders of the traits will also get the virtue_owner_modifier/sin_owner_modifier for each matching trait.
		# Virtues and sins can optionally have a multiplier to scale the effects (default is 1):
		virtues = { brave = 0.5 }		# scales both the opinion effect and the modifier
		# And they can specify a custom modifier (default is virtue_owner_modifier/sin_owner_modifier):
		# Scale is optional defaults to 1
		# Weight is optional defaults to 1. If there are two (or more) the same traits then the weight will be taken into account and is used to decide what and how a trait should be used
		sins = { stubborn = { modifier = modifier_key scale = 2 weight = 2 } }
	}

	reserved_male_names = { ... }	# Names listed here will be applied to all faiths that don't define reserved_male_names themselves.
	reserved_female_names = { ... }
	custom_faith_icons = { name name2 name3 } # When creating a custom faith, these will be the available icons. Path is  "gfx/interface/icons/faith/%s.dds", where %s is the name. Also needs a text icon

	localization = { ... }			# See localization inside faiths below.

	# Names and CoAs that can be used by holy orders of this religion. These are used if there are none available for the faith.
	# If there are none left here, it uses "holy_order_default" as name and a randomly generated CoA instead.
	holy_order_names = {
		{ name = "holy_order_name1" coat_of_arms = "holy_order_coa1" }
		{ name = "holy_order_name2" coat_of_arms = "holy_order_coa2" }
		...
	}

	# Men-At-Arms types mostly used for holy orders (see also: RELIGION_MAA_RATIO define)
	# The culture of the headquarters of the holy order must have unlocked the required innovation. (It will use the last available type in the list.)
	holy_order_maa = { regiment_type_1 regiment_type_2 ... }

	faiths = {
		faith_name = {
			color = { r g b }
			icon = faith_name # If you want to use another faith's icon
			graphical_faith = catholic_gfx # This faith (and custom faiths based on this faith) use this 3D model (currently used for temple assets). Order of precedence is the lowest level scripted in: faith > religion > family.
			piety_icon_group = christian 	# This faith (and custom faiths based on this faith) use this set of piety icons. Order of precedence is the lowest level scripted in: faith > religion > family.
			doctrine_background_icon = 	# This faith (and custom faiths based on this faith) use this doctrine background icon. Order of precedence is the lowest level scripted in: faith > religion > family.
			religious_head = title_key # What title should be this faith's religious head. If not set, will not have a religious head (unless created elsewhere in script)
			
			holy_site = holy_site_name # Holy site, as defined in the holy_site folder. You can add any number of these
			
			doctrine = name
			doctrine = another_name 	# The faith will have these doctrines

			reserved_male_names = { Hormazd Isaac }	# Names listed here will not be chosen as random names for characters of other faiths, unless these faiths also allow the name.
			reserved_female_names = { Maria }		# ... Note that these names refer to the "base names" of the names mentioned in the culture definitions (see _cultures.info).

			localization = {						# Key-value pairs for religion- or faith-dependent localizations. Can be accessed via "[Faith.key]" and "[Faith.random_key]", or even "[Faith.Custom('key')]" and "[Faith.RandomCustom('key')]"
				key = TAG							# Keys missing in the faith will be inherited from the religion.
				another_key = { TAGS MORE_TAGS }	# When there is more than one value, Faith.Custom returns the first value.
			}

			# Names and CoAs that can be used by holy orders of this faith.
			# If there are none (or none left), it will choose those in the religion instead.
			holy_order_names = {
				{ name = "mercenary_company_name1" coat_of_arms = "mercenary_company_coa1" }
				{ name = "mercenary_company_name2" coat_of_arms = "mercenary_company_coa2" }
				...
			}
		}
	}
}
