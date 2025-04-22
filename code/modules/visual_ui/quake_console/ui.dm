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
		/obj/abstract/visual_ui_element/console_background,
		/obj/abstract/visual_ui_element/console_input,
		/obj/abstract/visual_ui_element/console_output
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
	// Make all elements visible but off-screen (position above screen)
	for(var/obj/abstract/visual_ui_element/element in elements)
		element.invisibility = 0
		// Move elements above the screen (negative offset_y would move them below)
		element.offset_y = console_height * 32
		element.update_ui_screen_loc()
	// Begin animations - slide down into view (from offset_y to 0)
	for(var/obj/abstract/visual_ui_element/element in elements)
		element.animate_slide(0,  0.5 SECONDS) // Reduced from 300 to 100 for faster animation
	// Focus the input field
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
	for(var/obj/abstract/visual_ui_element/element in elements)
		element.animate_slide(console_height * 32, 0.5 SECONDS)
	spawn( 0.5 SECONDS)
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
	var/obj/abstract/visual_ui_element/console_output/output = locate(/obj/abstract/visual_ui_element/console_output) in elements
	if(output)
		output.add_line("> [text]")
		process_command(text, output)

	// Clear input field
	var/obj/abstract/visual_ui_element/console_input/input = locate(/obj/abstract/visual_ui_element/console_input) in elements
	if(input)
		input.set_text("")
		input.focus()

/datum/visual_ui/console/proc/process_command(text, obj/abstract/visual_ui_element/console_output/output)
	var/list/arg_list = splittext(text, " ")
	var/command = arg_list[1]
	arg_list.Cut(1, 2) // Remove the command, leaving only arguments

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
		output.add_line("Unknown command: [command]")
		output.add_line("Type 'help' for available commands")
