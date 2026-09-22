=== Notes ===

Decisions are sorted by the order in the script files (and thus the order of the script files themselves).

Major decisions are highlighted in the list, and will be considered important by default.
Important decisions will spawn an Action when they can be taken. The player can change whether or not a decision type is important to them.

=== Structure ===

my_decision = {
	title = <key> | { ... }			# override title, default: "<key>"; supports dynamic descriptions like in events (first_valid, ...); scope: character

	### Brief: picture
	# A picture to use for the decision.
	# In case that there are multiple the first one that fits the trigger will be the one selected.
	picture = {
		### Brief: trigger ( jomini trigger )
		# Receives the character scope to check if it's valid.
		# Empty triggers always pass on default so do not type a trigger if you want it to always succeed.
		trigger = { ... }

		### Brief: reference ( string path )
		# Path to the texture
		reference = "gfx/interface/illustrations/my/example/illustration.dds"

		### Brief: soundeffect ( sound effect name )
		# Name of the sound effect played when showing the decision details
		# Default: "event:/SFX/UI/Generic/Windows/sfx_ui_generic_window_standard_show"
		soundeffect = "event:/SFX/UI/Generic/Windows/sfx_ui_generic_window_sidebar"
	}

	extra_picture = "image_name.dds"# set extra decision image, for use in example Struggle decission buttons.

	decision_group_type = <key>		# Foldable decision group type to put this decision in. Default or not specified will select 'decisions'

	### Brief: progress
	# A value in range 0-100 representing how close to taking this decision a ruler is.
	# This us used for the progress bar in the Ruler Objective view.
	# root: Ruler (character)
	progress = <scripted value>

	### Brief: advice
	# Collection of advice, with their shared configuration.
	#
	advice = {

		### Brief: region
		#
		# The region to source potential target titles from when
		# producing Ruler Objective advice.
		# Every piece of advice (aka. every hint) will be evaluated with
		# every title in this region, and the best title for the advice
		# will be selected for that advice.
		#
		region = <geographical region>

		## Brief: per_title_hint
		# A piece of advice to evaluate for all titles in the geographical region.
		#
		# Shared scopes:
		# root –  Decision taker (player character).
		# title – The title to evaluate.
		# doing - Is the player already doing this? (added after the corresponding trigger)
		#
		# TODO_TGP: Deprecated. Migrate to ruler objective type database so what we can remove this.
		per_title_hint = {

			### Brief: is_valid
			# Trigger – Is this at all relevant advice for the provided title?
			# (Note: Renamed to is_valid_for_title in the advice database)
			is_valid = {
				debug_only = <yes/no>
			}

			### Brief: is_doing
			# Is the player currently doing what this advice recommends with the provided title?
			#
			# The result of this trigger is added to the scope as 'doing',
			# and is available to all evaluations below this one.
			# Advice that the player is already following is always preferred
			# over new recommendations.
			#
			is_doing = {
				always = <yes/no>
			}

			### Brief: relevance
			# How valuable this this advice with the given title.
			#
			# Higher value is better advice, and top ones are presented to the player.
			# Advice where the best variants relevance is lower than the define
			# ADVICE_RELEVANCE_LIMIT (default 0) is ignored entirely.
			#
			relevance = <script value>

			### Brief: summary
			# Short 'call to action' displayed on the advice button in the UI.
			summary = <dynamic desc>

			### Brief: description
			# Detailed explanation on what the player is advised to do,
			# how to do it, and why it is may be a good idea.
			description = <dynamic desc>
		}
	}

	ai_goal = yes/no 				# If set, the AI will consider the decision a "goal" and consider it alongside major costs like title creation and holding construction. It will ignore ai_check_interval. Should only be used for things with such major costs that budgeting for it is important, as it is less performant than using a high ai_check_interval

	ai_check_interval = 42			# How many months to go between each check of this decision. Has to be set (or 'ai_check_interval_by_tier') , except if ai_goal = yes is set. An interval of 0 means the AI will never check this decision.
	ai_check_interval_by_tier = {	# How often should the ai check this decision by tier of top title (in months). '0' means it is never considered. Used instead of 'ai_check_interval'. All tiers are required to be defined.
		barony = 0
		county = 10
		duchy = 2
		kingdom = 1
		empire = 1
		hegemony = 1
	}

	sort_order = integer			# The order that the decision should show up in the decision view relative to other decisions, higher number is sorted first, tie breaking is on definition order if same sort order

	selection_tooltip = <key> | { ... } # override tooltip when selecting the decision from the decision list, default: "<key>_tooltip"; supports dynamic descriptions like in events (first_valid, ...); scope: character
	desc = <key> | { ... }			# override description, default: "<key>_desc"; supports dynamic descriptions like in events (first_valid, ...); scope: character
	confirm_text = <key> | { ... }	# override confirm_text, default: "<key>_confirm"; supports dynamic descriptions like in events (first_valid, ...); scope: character

	is_shown = { ... }				# is decision available to the character; scope: character; default: { always = yes }
	is_valid_showing_failures_only = { ... }	# can execute decision; these will be shown in the confirm button tooltip if they fail; scope: character; default: { always = yes }
	is_valid = { ... }				# can execute decision; these will be shown in the detail view under Requirements; scope: character; default: { always = yes }

	cost = {						# cost values, default: 0
		gold = 42
		piety = 42
		prestige = 42
	}
	minimum_cost = {}				# Like 'cost', except this doesn't get applied. It'll block taking the decision if not affordable. For use in places that apply the cost after the fact based on player input and the like

	should_create_alert = {			# Should this decision have an alert made for it, applied on top of the usual requirements that the decision will be alerted for
		...
	}

	effect = { ... }				# effect to execute when decision is taken; scope: character

	ai_potential = { ... }			# trigger whether the AI should look at it or not
	ai_will_do = { ... }			# Returns the % chance of executing executing the decision. 0 will never execute it, 100 will alwasy execute it. Will also determine the default option (if the decision has those) for players .

	# Specify up to one custom widget to embed in the decision. See section about Custom Widgets below.
	widget = {
		# Name of the widget to use. Must be at the path <decision_view_widgets>/<widget_name>.gui
		gui = "<widget_name>"
		# Some widgets require a custom controller (see below). Default: default
		controller = "<controller_type>"

		show_from_start = yes # Shows the option list from the very beginning of the decision window flow

		# One or more options (add an item = {} entry for each option)
		# Available if you have `controller = decision_option_list_controller`
		item = {
			value = entry_name			# is used in effect section
			is_shown = trigger 			# is entry shown
			is_valid = trigger 			# is entry selectable
			current_description = desc 	# tooltip info
			localization = loc_key 		# what should be shown in the list
			is_default = bool	 		# is the default entry to pick
			icon = "icon/file/path.dds"	# path to the icon
			flat = no					# is icon flat black and needs a special widtet, or is it full color

			# Which item should the AI use (+ which is the default for the player)
			# NOTE! The highest scoring item is selected - there is no randomization.
			# This is also used to select the default option for players. To get a proper "decision available"
			# notification for each item, make sure that the item has the highest score if it is available!
			ai_chance = score
		}
	}
	widget = "<controller_type>"	# alternative short syntax, gui will be "decision_view_widget_<controller_type>"
}

=== Custom Widgets ===

A custom widget can be embedded into a decision.
GUI files must be placed at the decision_view_widgets path (see paths.settings). The name of the file must match the widget name.

Usually these widgets require a custom controller. This should be documented in the widget's GUI file.
The data context type available in the GUI depends on the controller type.

Available controllers:

Controller Type						| Data Context Name				  		| Notes
------------------------------------+---------------------------------------+-----------------------------------------------------------
default								| EventWindowWidget				  		| Default controller, no special behavior
create_holy_order 					| DecisionViewWidgetCreateHolyOrder  	| Show GUI to customize the new holy order.
decision_option_list_controller 	| DecisionViewWidgetOptionList 			| Shows a GUI to pick an option that sets a flag for the effect, see the `item = { ... }` description above

