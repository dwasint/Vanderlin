
// Output field
/obj/abstract/visual_ui_element/console_output
	name = "Console Output"
	icon = 'icons/visual_ui/32x32.dmi'
	icon_state = "blank"
	mouse_opacity = 0
	var/list/lines = list()
	var/max_lines = 100

/obj/abstract/visual_ui_element/console_output/New(turf/loc, datum/visual_ui/P)
	. = ..()
	offset_y = 0
	update_ui_screen_loc()

	// Add welcome message
	add_line("Quake-Style Console")
	add_line("Type 'help' for available commands")

/obj/abstract/visual_ui_element/console_output/UpdateIcon(appear = FALSE)
	cut_overlays()

	// Background
	var/image/background = image('icons/visual_ui/32x32.dmi', "blank")
	var/matrix/M = matrix()
	M.Scale(20, ((parent.vars["console_height"] || 14) - 3)) // Full console height minus input and borders
	background.transform = M
	background.color = "#000000"
	background.alpha = 100
	add_overlay(background)

	// Text output
	var/image/text_image = image(icon = null)
	var/display_text = ""

	// Show last 20 lines max (or however many fit in our console)
	var/available_lines = min(((parent.vars["console_height"] || 14) - 3) * 2, lines.len)
	var/start_line = max(1, lines.len - available_lines + 1)

	for(var/i = start_line to lines.len)
		display_text += "[lines[i]]<br>"

	text_image.maptext = {"<span style='color:#00FF00;font-size:8pt;font-family:\"Consolas\";'>[display_text]</span>"}
	text_image.maptext_width = 640
	text_image.maptext_height = 512
	text_image.maptext_x = 5
	text_image.maptext_y = 8
	add_overlay(text_image)

/obj/abstract/visual_ui_element/console_output/animate_slide(target_y, duration)
	slide_ui_element(offset_x, target_y, duration)

/obj/abstract/visual_ui_element/console_output/proc/add_line(text)
	lines += text
	if(lines.len > max_lines)
		lines.Cut(1, 2) // Remove oldest line
	UpdateIcon()

/obj/abstract/visual_ui_element/console_output/proc/clear()
	lines.Cut()
	UpdateIcon()
