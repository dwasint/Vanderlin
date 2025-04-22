/datum/console_command/update
	command_key = "update"

/datum/console_command/update/help_information(obj/abstract/visual_ui_element/scrollable/console_output/output)
	output.add_line("update {VAR} value - checks and sets the var specified")
	output.add_line("    Keywords: src = sender")
	output.add_line("    usr = sender")
	output.add_line("    here = senders turf")
	output.add_line("    marked = marked datum")
	output.add_line("    loc = senders loc")

/datum/console_command/update/execute(obj/abstract/visual_ui_element/scrollable/console_output/output, list/arg_list)
	var/variable = arg_list[1]
	var/value = output.parent:convert_arg_type(arg_list[2], output.parent.mind.current, output.parent.mind.current.client.holder?.marked_datum)

	var/atom/user = output.parent.mind.current
	var/datum/marked_datum = output.parent.mind.current.client.holder?.marked_datum
	if(marked_datum)
		user = marked_datum

	if(!(variable in user.vars))
		output.add_line("ERROR: variable not in list")
		return

	user.vars[variable] = value
	output.add_line("[variable] set to [value]")
	return TRUE
