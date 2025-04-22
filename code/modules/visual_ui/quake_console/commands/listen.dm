/datum/console_command/listen
	command_key = "listen"
	required_args = 1

/datum/console_command/listen/help_information(obj/abstract/visual_ui_element/scrollable/console_output/output)
	output.add_line("listen {SIGNAL} - will output the variables of the supplied signal on the marked datum every time its triggered")

/datum/console_command/listen/execute(obj/abstract/visual_ui_element/scrollable/console_output/output, list/arg_list)
	. = ..()
	var/signal = arg_list[1]

	var/datum/marked_datum = output.parent.mind.current.client.holder?.marked_datum
	if(!marked_datum)
		output.add_line("ERROR: No marked datum")
		return
	output.parent:setup_listen(signal, marked_datum)
