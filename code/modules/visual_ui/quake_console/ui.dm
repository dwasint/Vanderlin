/datum/visual_ui/console
	uniqueID = "quake_console"
	x = "CENTER"
	y = "NORTH"
	var/console_height = 14 // height in tiles
	var/console_open = FALSE
	var/list/command_history = list()
	var/history_position = 0
	var/current_input = ""

	element_types_to_spawn = list(
		/obj/abstract/visual_ui_element/console_input,
		/obj/abstract/visual_ui_element/scrollable/console_output
	)

/datum/visual_ui/console/New(datum/mind/M)
	. = ..()
	hide()

/datum/visual_ui/console/proc/toggle()
	if(console_open)
		close_console()
	else
		open_console()
/datum/visual_ui/console/proc/open_console()
	if(console_open)
		return
	console_open = TRUE
	display()
	var/obj/abstract/visual_ui_element/console_input/input = locate(/obj/abstract/visual_ui_element/console_input) in elements
	if(input)
		input.focus()

/datum/visual_ui/console/proc/close_console()
	if(!console_open)
		return
	console_open = FALSE
	var/obj/abstract/visual_ui_element/console_input/input = locate(/obj/abstract/visual_ui_element/console_input) in elements
	if(input)
		input.unfocus()
	if(!console_open)
		hide()

/datum/visual_ui/console/proc/submit_command(text)
	if(!text || text == "")
		return

	// Add to history
	command_history.Insert(1, text)
	if(command_history.len > 50) // Limit history length
		command_history.Cut(51)

	history_position = 0
	current_input = ""

	// Process command
	var/obj/abstract/visual_ui_element/scrollable/console_output/output = locate(/obj/abstract/visual_ui_element/scrollable/console_output) in elements
	if(output)
		output.add_line("> [text]")
		process_command(text, output)

	var/obj/abstract/visual_ui_element/console_input/input = locate(/obj/abstract/visual_ui_element/console_input) in elements
	if(input)
		input.set_text("")
		input.focus()

/datum/visual_ui/console/proc/process_command(text, obj/abstract/visual_ui_element/scrollable/console_output/output)
	var/list/arg_list = splittext(text, " ")
	var/command = arg_list[1]
	arg_list.Cut(1, 2)

	var/executed = FALSE
	for(var/datum/console_command/listed_command in GLOB.console_commands)
		if(command != listed_command.command_key)
			continue
		if(!listed_command.can_execute(mind.current))
			continue
		listed_command.execute(output, arg_list)
		executed = TRUE
		break

	if(!executed)
		try_proccall(command, arg_list, output)

/datum/visual_ui/console/proc/try_proccall(procname, list/arg_list, obj/abstract/visual_ui_element/scrollable/console_output/output)
	if(!mind?.current?.client || !check_rights(R_DEBUG, FALSE, mind.current.client))
		output.add_line("Unknown command: [procname]")
		output.add_line("Type 'help' for available commands")
		return

	// Parse named arguments (key=value pairs)
	var/list/named_args = list()
	var/list/positional_args = list()

	for(var/arg in arg_list)
		if(findtext(arg, "="))
			var/list/key_val = splittext(arg, "=")
			if(length(key_val) == 2)
				named_args[key_val[1]] = convert_arg_type(key_val[2], mind.current, mind.current.client.holder?.marked_datum)
		else
			positional_args += convert_arg_type(arg, mind.current, mind.current.client.holder?.marked_datum)

	// Combine positional and named args
	var/list/final_args = positional_args.Copy()
	if(length(named_args))
		final_args += named_args

	// First try on the user's mob or marked datum
	var/atom/user = mind.current
	var/datum/marked_datum = mind.current.client.holder?.marked_datum
	if(marked_datum)
		user = marked_datum
	var/proc_found = FALSE
	var/returnval

	if(hascall(user, procname))
		proc_found = TRUE
		returnval = WrapAdminProcCall(user, procname, final_args)
	else
		// Try global procs
		var/procpath = "/proc/[procname]"
		if(text2path(procpath))
			proc_found = TRUE
			returnval = WrapAdminProcCall(GLOBAL_PROC, procname, final_args)

	if(!proc_found)
		output.add_line("Unknown command or proc: [procname]")
		output.add_line("Type 'help' for available commands")
		return

	// Display return value
	var/return_text = mind.current.client.get_callproc_returnval(returnval, procname)
	if(return_text)
		output.add_line(return_text)

/datum/visual_ui/console/proc/convert_arg_type(arg, mob/sender, datum/marked)
	switch(lowertext(arg))
		if("src")
			return sender
		if("marked")
			return marked
		if("usr")
			return sender
		if("here")
			return get_turf(sender)
		if("loc")
			return sender?.loc

	if(isnum(arg) || isnum(text2num(arg)))
		return text2num(arg)

	var/path = text2path(arg)
	if(path)
		return path

	switch(lowertext(arg))
		if("true", "yes", "on")
			return TRUE
		if("false", "no", "off")
			return FALSE
		if("null")
			return null

	// Check if it's a list (comma-separated)
	if(findtext(arg, ","))
		var/list/result = list()
		for(var/item in splittext(arg, ","))
			result += convert_arg_type(trim(item), sender, marked)
		return result

	// Default to string
	return arg
