GLOBAL_LIST_INIT(console_commands, init_possible_commands())

/proc/init_possible_commands()
	var/list/commands = list()
	for(var/datum/console_command/command as anything in subtypesof(/datum/console_command))
		commands |= new command
	return commands

/datum/console_command
	var/command_key

/datum/console_command/proc/help_information(obj/abstract/visual_ui_element/scrollable/console_output/output)
	return

/datum/console_command/proc/can_execute(mob/anchor)
	return TRUE

/datum/console_command/proc/execute(obj/abstract/visual_ui_element/scrollable/console_output/output, list/arg_list)
	return TRUE

