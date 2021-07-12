== Structure ==

lesson_chain_name = { # arbitrary name
	trigger = { ... }	# The trigger has to be true for the lesson chain to start
	delay = X			# The chain start will be delayed by that many seconds

	# Is this the "railroaded" tutorial, where the player is guided through fixed lessons?
	# This mode cannot be used in MP, instead this is activated when selecting to play "the tutorial" in the bookmark screen.
	# Progress will be saved in the save game ("gamestate") instead of globally (in tutorial.txt).
	# When this mode is disabled (e.g. via finish_gamestate_tutorial = yes in a lesson), chains with save_progress_in_gamestate = yes cannot be triggered anymore.
	# Required for pausing game or running effects from tutorial steps.
	# Default: no
	save_progress_in_gamestate = yes/no
}
