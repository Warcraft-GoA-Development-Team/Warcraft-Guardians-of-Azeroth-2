<key> = {
	# for grouping together contract types, e.g. mercenary, potentially determines map icon
	group = test_group

	# Icon used in the UI
	icon = "path/to/image.dds"

	# Description or 'back-story' of the task contract, defaults to "<key>_desc"
	# root = task_contract_type
	desc = ""

	# Description for request telling 'what to do' in order to complete the contract, defaults to "<key>_request"
	# root = task_contract_type
	task_contract_request = ""

	# Contract owner should travel to contract location to accept and stay there for the duration of the contract
	travel = no

	# Contract is of a criminal nature
	is_criminal = no

	# Range setting
	# yes - uses diplomatic range to contract employer
	# no - uses ADVENTURER_DISTANCE_RESTRICTION define as radius
	use_diplomatic_range = no

	# Validity Triggers
	## Can contract appear? (if triggers are true)
	# root - contract owner
	# scope:employer - contract employer, can be empty
	valid_to_create = {
		<trigger>
	}

	# Can contract be accepted? (if triggers are true)
	# root - contract owner
	# scope:employer - contract employer, can be empty
	valid_to_accept = {
		<trigger>
	}

	# Should contract invalidate? (if triggers are false)
	# root - existing contract
	valid_to_continue = {
		<trigger>
	}

	# Should not taken contract invalidate? (if triggers are false)
	# root - existing contract
	valid_to_keep = {
		<trigger>
	}

	# On-Action Effects
	## Effects called when contract is created (create_task_contract effect)
	on_create = {
		<effects>
	}

	## Effects called when contract is accepted (accept_task_contract effect)
	on_accepted = {
		<effects>
	}

	# Effects called when contract is completed successfully, along with rewards (complete_task_contract effect)
	on_completed = {
	    <effects>
	}

	# Effects called when contract is invalidated (valid_to_continue is false, or invalidate_task_contract effect)
	on_invalidated = {
	    <effects>
	}
	
	# Default = no, showing completed contract toast animation
	should_show_toast_on_complete = no 

	# Contract Reward Effects
	task_contract_reward = {
		#reward name
		<string> = {
			# Default = no, showing completed contract reward effect desription
			should_print_on_complete = no
			effect = {
				<effects>
			}

			# Should this possible reward be shown in the UI. It will still be displayed in the effect on completion
			# if that's what owner gets
			visible = yes

			# Is this reward positive 'Upon Success' or negative 'Upon Failure'
			# default is yes
			positive = yes
		}
	}

	# scripted value how likely this contract type is to be picked when populating for area
	# root - contract owner
	# scope:employer - contract employer, can be empty
	weight = {
		value = 0
	}
}
