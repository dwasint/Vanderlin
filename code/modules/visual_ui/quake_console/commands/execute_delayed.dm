/datum/console_command/execute_delayed
	command_key = "execute_delayed"
	required_args = 3

/datum/console_command/execute_delayed/help_information(obj/abstract/visual_ui_element/scrollable/console_output/output)
	output.add_line("execute_delayed {SIGNAL} {TIME} {PROC} - will trigger set proc when the signal is recieved on the mob")
	output.add_line("  variables can be set as named by going {VAR}={VALUE}")
	output.add_line("  time is set in seconds")

/datum/console_command/execute_delayed/execute(obj/abstract/visual_ui_element/scrollable/console_output/output, list/arg_list)
	. = ..()
	var/signal = arg_list[1]
	arg_list -= signal

	var/datum/marked_datum = output.parent.mind.current.client.holder?.marked_datum
	if(!marked_datum)
		output.add_line("ERROR: No marked datum")
		return
	output.parent:setup_execute_delayed(signal, marked_datum, arg_list)
