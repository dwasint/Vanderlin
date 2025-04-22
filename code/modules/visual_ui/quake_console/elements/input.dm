/obj/abstract/visual_ui_element/console_input
	name = "Console Input"
	icon = 'icons/visual_ui/quake_console.dmi'
	icon_state = "quake_input"
	layer = VISUAL_UI_BUTTON
	mouse_opacity = 1
	offset_x = -190
	offset_y = -215

	///modifiers
	var/shift_down = FALSE
	var/ctrl_down = FALSE
	var/alt_down = FALSE

	var/input_text = ""
	var/cursor_position = 0
	var/cursor_visible = TRUE
	var/cursor_blink_timer
	var/focused = FALSE  // Whether this console is currently focused

/obj/abstract/visual_ui_element/console_input/New(turf/loc, datum/visual_ui/P)
	. = ..()
	update_ui_screen_loc()
	// Start cursor blinking
	cursor_blink_timer = addtimer(CALLBACK(src, PROC_REF(blink_cursor)), 5, TIMER_STOPPABLE|TIMER_LOOP)

/obj/abstract/visual_ui_element/console_input/proc/blink_cursor()
	cursor_visible = !cursor_visible
	UpdateIcon()

/obj/abstract/visual_ui_element/console_input/UpdateIcon(appear = FALSE)
	cut_overlays()
	var/display_text = input_text
	if(cursor_visible && focused)  // Only show cursor when focused
		if(cursor_position >= length(input_text))
			display_text += "_"
		else
			display_text = copytext(display_text, 1, cursor_position + 1) + "_" + copytext(display_text, cursor_position + 1)
	// Input text
	var/image/text_image = image(icon = null)
	text_image.maptext = {"<span style='color:#00FF00;font-size:8pt;font-family:\"Consolas\";'>>[display_text]</span>"}
	text_image.maptext_width = 640
	text_image.maptext_height = 32
	text_image.maptext_x = 5
	text_image.maptext_y = 8
	add_overlay(text_image)


/obj/abstract/visual_ui_element/console_input/proc/set_text(new_text)
	input_text = new_text
	cursor_position = length(input_text)
	UpdateIcon()

/obj/abstract/visual_ui_element/console_input/proc/focus()
	// Get all console inputs and unfocus them first
	var/mob/user = get_user()
	if(user)
		for(var/obj/abstract/visual_ui_element/console_input/other_input in user.client?.screen)
			if(other_input != src)
				other_input.unfocus()

	focused = TRUE
	UpdateIcon()
	// Block normal keyboard input
	var/mob/user_mob = get_user()
	if(user_mob)
		user_mob.focus = src

/obj/abstract/visual_ui_element/console_input/proc/unfocus()
	focused = FALSE
	UpdateIcon()
	// Restore normal keyboard input
	var/mob/user_mob = get_user()
	user_mob.focus = user_mob

/obj/abstract/visual_ui_element/console_input/Click(location, control, params)
	focus()
	return TRUE

/obj/abstract/visual_ui_element/console_input/proc/handle_keydown(key)
	if(!focused)
		return FALSE

	// Handle modifier keys
	switch(key)
		if("Shift")
			shift_down = TRUE
			return TRUE
		if("Ctrl")
			ctrl_down = TRUE
			return TRUE
		if("Alt")
			alt_down = TRUE
			return TRUE

	var/reading_key = key
	// Intercept keystrokes and hand	le them
	var/special_key = FALSE
	switch(key)
		if("Backspace", "Back")
			special_key = TRUE
			if(cursor_position > 0)
				input_text = copytext(input_text, 1, cursor_position) + copytext(input_text, cursor_position + 1)
				cursor_position--
		if("Delete")
			special_key = TRUE
			if(cursor_position < length(input_text))
				input_text = copytext(input_text, 1, cursor_position + 1) + copytext(input_text, cursor_position + 2)
		if("Left", "West")
			special_key = TRUE
			cursor_position = max(0, cursor_position - 1)
		if("Right", "East")
			special_key = TRUE
			cursor_position = min(length(input_text), cursor_position + 1)
		if("Home")
			special_key = TRUE
			cursor_position = 0
		if("End")
			special_key = TRUE
			cursor_position = length(input_text)
		if("Up", "North")
			special_key = TRUE
			var/datum/visual_ui/console/console = parent
			if(istype(console) && console.history_position < length(console.command_history))
				console.history_position++
				set_text(console.command_history[console.history_position])
		if("Down", "South")
			special_key = TRUE
			var/datum/visual_ui/console/console = parent
			if(istype(console))
				if(console.history_position > 1)
					console.history_position--
					set_text(console.command_history[console.history_position])
				else if(console.history_position == 1)
					console.history_position = 0
					set_text(console.current_input)
		if("Enter", "Return")
			special_key = TRUE
			var/datum/visual_ui/console/console = parent
			if(istype(console))
				console.submit_command(input_text)
		if("Escape")
			special_key = TRUE
			var/datum/visual_ui/console/console = parent
			if(istype(console))
				console.close_console()
		if("Space")
			special_key = TRUE
			input_text = copytext(input_text, 1, cursor_position + 1) + " " + copytext(input_text, cursor_position + 1)
			cursor_position++

	// If not a special key, handle as normal character (in keyUp)
	if(special_key)
		// Save current input for history
		var/datum/visual_ui/console/console = parent
		if(istype(console))
			console.current_input = input_text

		UpdateIcon()
		return TRUE

	return TRUE

/obj/abstract/visual_ui_element/console_input/proc/handle_keyup(key)
	if(!focused)
		return FALSE

	if(key == "`")
		return TRUE
	// Handle modifier keys
	switch(key)
		if("Shift")
			shift_down = FALSE
			return TRUE
		if("Ctrl")
			ctrl_down = FALSE
			return TRUE
		if("Alt")
			alt_down = FALSE
			return TRUE

	// Check for character input (not special keys)
	if(length(key) == 1 && key != " ")
		// Apply shift modifier if needed
		var/char_to_add = key
		if(shift_down)
			char_to_add = uppertext(char_to_add)
		else
			char_to_add = lowertext(char_to_add)

		input_text = copytext(input_text, 1, cursor_position + 1) + char_to_add + copytext(input_text, cursor_position + 1)
		cursor_position++

		// Save current input for history
		var/datum/visual_ui/console/console = parent
		if(istype(console))
			console.current_input = input_text

		UpdateIcon()
		return TRUE

	return FALSE

/obj/abstract/visual_ui_element/console_input/Destroy()
	deltimer(cursor_blink_timer)
	unfocus()
	return ..()
