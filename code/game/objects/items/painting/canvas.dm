/obj/item/canvas
	name = "canvas"
	desc = "A perfect place to paint"

	icon = 'icons/paint_supplies/canvas_32.dmi'
	icon_state = "canvas"

	var/easel_offset = 9
	var/canvas_size_x = 32
	var/canvas_size_y = 32

	var/atom/movable/screen/canvas/used_canvas
	var/list/showers = list()

	var/icon/draw

	var/title
	var/author
	var/author_ckey
	var/canvas_size = "32x32"

	var/canvas_icon = 'icons/paint_supplies/canvas/canvas_32x32.dmi'
	var/canvas_icon_state = "canvas"
	var/canvas_screen_loc = "6,6"
	var/canvas_divider_x = 5
	var/canvas_divider_y = 5
	var/pixel_size_x = 4
	var/pixel_size_y = 4

/obj/item/canvas/Initialize()
	. = ..()
	used_canvas = new
	used_canvas.host = src
	used_canvas.base_icon = icon(icon, icon_state)
	used_canvas.icon = canvas_icon
	used_canvas.screen_loc = canvas_screen_loc
	used_canvas.icon_state = canvas_icon_state
	draw = icon(icon, icon_state)
	RegisterSignal(src, COMSIG_MOVABLE_TURF_ENTERED, PROC_REF(remove_showers))

/obj/item/canvas/Destroy()
	. = ..()
	for(var/mob/mob in showers)
		remove_shower(mob)

/obj/item/canvas/attack_right(mob/user)
	. = ..()
	if(user.get_active_held_item())
		return
	if(user in showers)
		return
	user?.client.screen += used_canvas
	showers |= user
	RegisterSignal(user, COMSIG_MOVABLE_TURF_ENTERED, PROC_REF(remove_shower))

/obj/item/canvas/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/natural/feather))
		author = input("Who's the author of this painting?")
		author_ckey = user.ckey
		title = input("What's the title of this painting.")
		if(title)
			name = title
		if(author)
			desc = "Painted by: [author]."

		return

	if(!istype(I, /obj/item/paint_brush))
		return
	if(user in showers)
		return
	user?.client.screen += used_canvas
	showers |= user

/obj/item/canvas/proc/remove_showers()
	for(var/mob/mob in showers)
		remove_shower(mob)

/obj/item/canvas/proc/remove_shower(mob/source)
	showers -= source
	source.client?.screens -= used_canvas
	UnregisterSignal(source, COMSIG_MOVABLE_TURF_ENTERED)

/obj/item/canvas/proc/update_drawing(x, y, current_color)
	draw.DrawBox(current_color, x, y)

	icon = draw

/obj/item/canvas/proc/upload_painting()
	if(!author || !title)
		return
	SSpaintings.playerpainting2file(draw, title, author, author_ckey, canvas_size)
	SSpaintings.update_paintings()

/atom/movable/screen/canvas
	icon = 'icons/paint_supplies/canvas/canvas_32x32.dmi'
	icon_state = "canvas"
	screen_loc = "6,6"

	var/obj/item/canvas/host

	var/icon/draw

	var/list/modified_areas = list()
	var/icon/base_icon


/atom/movable/screen/canvas/Initialize(mapload, ...)
	. = ..()
	draw = icon(icon, icon_state)

/atom/movable/screen/canvas/Click(location, control, params)
	. = ..()
	var/obj/item/paint_brush/brush = usr.get_active_held_item()
	if(!istype(brush))
		return
	var/current_color = brush.current_color
	var/list/param_list = params2list(params)

	var/x = text2num(param_list["icon-x"])
	var/y = text2num(param_list["icon-y"])

	y = min(FLOOR(y / host.canvas_divider_y, 1), host.canvas_size_y)
	x = min(FLOOR(x / host.canvas_divider_y, 1), host.canvas_size_x)

	if(param_list["right"])
		var/original_color = base_icon.GetPixel(x, y)
		current_color = original_color
		modified_areas -= "[x][y]"
	else

		if("[x][y]" in modified_areas)
			var/pre_merge = draw.GetPixel(x, y)
			if(pre_merge != current_color)
				current_color = BlendRGB(current_color, pre_merge, 0.5)
		modified_areas |= "[x][y]"

	draw.DrawBox(current_color, x*host.canvas_divider_x, y*host.canvas_divider_y, (x*host.canvas_divider_x) + host.pixel_size_x, (y*host.canvas_divider_y) + host.pixel_size_y)
	host.update_drawing(x+1, y+1, current_color)

	icon = draw

/obj/item/random_painting/Initialize()
	. = ..()
	icon = SSpaintings.get_random_painting("32x32")
