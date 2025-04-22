/obj/abstract/visual_ui_element/console_background
	name = "Console Background"
	icon = 'icons/visual_ui/32x32.dmi'
	icon_state = "blank"
	mouse_opacity = 0
	var/console_width = 14

/obj/abstract/visual_ui_element/console_background/UpdateIcon(appear = FALSE)
	cut_overlays()

	// Create a black rectangle with some opacity
	var/matrix/M = matrix()
	M.Scale(console_width, ((parent.vars["console_height"] || 14) - 2))

	var/image/background = image('icons/visual_ui/32x32.dmi', "background")
	background.transform = M

	add_overlay(background)
/obj/abstract/visual_ui_element/proc/animate_slide(target_y, duration)

/obj/abstract/visual_ui_element/console_background/animate_slide(target_y, duration)
	slide_ui_element(offset_x, target_y, duration)
