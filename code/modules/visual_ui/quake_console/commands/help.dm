/datum/console_command/help
	command_key = "help"

/datum/console_command/help/help_information(obj/abstract/visual_ui_element/scrollable/console_output/output)
	output.add_line("help - Display this help text")

/datum/console_command/help/execute(obj/abstract/visual_ui_element/scrollable/console_output/output, list/arg_list)
	output.add_line("Available commands:")
	for(var/datum/console_command/listed_command in GLOB.console_commands)
		if(!listed_command.can_execute(output.parent.mind.current))
			continue
		listed_command.help_information(output)
