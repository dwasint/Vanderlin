// rmd embeds this integration for the Forced bundled profile setting. To make the profile part of
// a Vanderlin checkout instead, copy it there and `#include` it from `vanderlin.dme`, the guard
// keeps BYOND compiling it to nothing.
//
// Vanderlin needs its globals and overlay subsystem stubbed before anything smooths, and its fluid
// pipes assemble an icon state from a connection list that normally fills in over two init passes.
#ifdef __DEMIR_BAKE__

/datum/controller/subsystem/overlays/demir_preview/New()
	SSoverlays = src
	stats = list()

/datum/controller/global_vars/demir_preview/New()
	GLOB = src
	if(!SSoverlays)
		SSoverlays = new /datum/controller/subsystem/overlays/demir_preview
	bitflag_lists = list()
	gvars_datum_init_order = list()
	InitGlobalcardinals()

/atom/proc/demir_prepare_smoothing()
	SETUP_SMOOTHING()

// MOVABLE_LIGHT uses a pre-baked mask in vis_contents. Emit the same mask as a tagged underlay so
// the editor can composite it after static lighting without starting components or signals.
/proc/demir_vanderlin_overlay_icon(pixel_bounds)
	switch(pixel_bounds)
		if(32)
			return 'icons/effects/light_overlays/light_32.dmi'
		if(64)
			return 'icons/effects/light_overlays/light_64.dmi'
		if(96)
			return 'icons/effects/light_overlays/light_96.dmi'
		if(128)
			return 'icons/effects/light_overlays/light_128.dmi'
		if(160)
			return 'icons/effects/light_overlays/light_160.dmi'
		if(192)
			return 'icons/effects/light_overlays/light_192.dmi'
		if(224)
			return 'icons/effects/light_overlays/light_224.dmi'
		if(256)
			return 'icons/effects/light_overlays/light_256.dmi'
		if(288)
			return 'icons/effects/light_overlays/light_288.dmi'
		if(320)
			return 'icons/effects/light_overlays/light_320.dmi'
		if(352)
			return 'icons/effects/light_overlays/light_352.dmi'
		if(384)
			return 'icons/effects/light_overlays/light_384.dmi'
		if(416)
			return 'icons/effects/light_overlays/light_416.dmi'
		if(448)
			return 'icons/effects/light_overlays/light_448.dmi'
		if(480)
			return 'icons/effects/light_overlays/light_480.dmi'
		if(512)
			return 'icons/effects/light_overlays/light_512.dmi'
		if(544)
			return 'icons/effects/light_overlays/light_544.dmi'
	return null

/atom/movable/proc/demir_add_overlay_light()
	if(light_system != MOVABLE_LIGHT || !light_on || !light_outer_range)
		return
	demir_add_light_mask(light_outer_range, light_color)

/atom/movable/proc/demir_add_light_mask(outer_range, mask_color)
	var/rounded_range = clamp(CEILING(outer_range, 0.5), 1, 9)
	var/pixel_bounds = ((rounded_range - 1) * 64) + 32
	var/image/mask = new
	mask.icon = demir_vanderlin_overlay_icon(pixel_bounds)
	mask.icon_state = "light2"
	mask.dir = dir
	mask.plane = O_LIGHTING_VISUAL_PLANE
	mask.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mask.alpha = 255
	mask.color = mask_color
	mask.pixel_x = -((pixel_bounds - 32) * 0.5)
	mask.pixel_y = mask.pixel_x
	mask.demir_overlay_light = 1
	underlays += mask

// A sconce sparks the torch it spawns in Initialize(), and the torch's light component hangs its
// mask on the sconce because the torch itself is not on a turf.
/obj/machinery/light/fueled/torchholder/demir_add_overlay_light()
	if(!ispath(torchy))
		return
	var/obj/item/flashlight/flare/torch/torch = torchy
	demir_add_light_mask(initial(torch.light_outer_range), initial(torch.light_color))

// Fixtures are STATIC_LIGHT, but their light vars stay at the type defaults until update() copies
// brightness, bulb_power and bulb_colour over them through set_light().
/obj/machinery/light/demir_prepare_light_state()
	light_on = on
	if(!on)
		return
	light_power = bulb_power
	light_color = color ? color : bulb_colour
	light_outer_range = brightness
	if(light_outer_range > 0 && light_outer_range < MINIMUM_USEFUL_LIGHT_RANGE)
		light_outer_range = MINIMUM_USEFUL_LIGHT_RANGE
	if(light_inner_range >= light_outer_range)
		light_inner_range = light_outer_range / 4
	light_falloff_curve = LIGHTING_DEFAULT_FALLOFF_CURVE

// `seton(TRUE)` from Initialize()
/obj/machinery/light/fueled/demir_prepare_light_state()
	on = status == LIGHT_OK
	..()

/obj/machinery/light/fueled/torchholder/demir_prepare_light_state()
	..()
	if(!torchy)
		on = FALSE
		light_on = FALSE

// `lights_on()` from Initialize()
/obj/machinery/light/fueledstreet/demir_prepare_light_state()
	on = TRUE
	..()

// Flashlights normally derive light_on from their mapped on/icon state during Initialize().
/obj/item/flashlight/demir_prepare_light_state()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	light_on = on

/obj/item/flashlight/flare/torch/prelit/demir_prepare_light_state()
	on = TRUE
	light_on = TRUE

/obj/item/flashlight/flare/torch/metal/prelit/demir_prepare_light_state()
	on = TRUE
	light_on = TRUE

/obj/item/clothing/head/helmet/leather/shaman_hood/demir_prepare_light_state()
	light_on = on

// Fluid pipes keep an associative list of connected directions keyed by the
// direction number, and assemble their icon state from those keys in list
// order. Each pipe links its neighbors pairwise from Initialize(), and
// adjacent machines link back from setup_water(). Baking every pipe from its
// own point of view reaches the same result without a load order.
/obj/structure/water_pipe/demir_bake_appearance()
	for(var/key in connected)
		connected[key] = 0

	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		if(!cardinal_turf)
			continue

		var/connects = (locate(/obj/structure/water_pipe) in cardinal_turf)
		if(!connects)
			for(var/obj/structure/structure in cardinal_turf)
				if(!structure.accepts_water_input)
					continue
				if(!structure.valid_water_connection(direction, src))
					continue
				connects = TRUE
				break

		if(connects)
			connected["[direction]"] = 1

	if(locate(/obj/structure/water_pipe) in demir_vertical_turf(1))
		connected["[UP]"] = 1
	if(locate(/obj/structure/water_pipe) in demir_vertical_turf(-1))
		connected["[DOWN]"] = 1

	update_appearance(UPDATE_OVERLAYS)

// `GET_TURF_ABOVE()` reads the mapping subsystem's z level links, which the
// editor never builds. Adjacent z levels stack instead, the way the viewer
// draws its underlays.
/obj/structure/water_pipe/proc/demir_vertical_turf(offset)
	var/turf/here = get_turf(src)
	if(!here)
		return null

	return locate(here.x, here.y, here.z + offset)

/datum/demir/vanderlin
	default = TRUE
	var/sun_color
	// Hour of the station day, 0 to 24, on the same scale as the `start` values on /datum/time_of_day.
	// 10 is the start of daytime, which matches the fixed noon tint this profile used before.
	var/tod_hours = 10
	var/tod_step_name = "Daytime"
	var/list/tod_steps

	New()
		..()
		if(!GLOB)
			GLOB = new /datum/controller/global_vars/demir_preview
		// Same order as SSoutdoor_effects.time_cycle_steps, midnight last.
		tod_steps = list(
			/datum/time_of_day/dawn,
			/datum/time_of_day/sunrise,
			/datum/time_of_day/daytime,
			/datum/time_of_day/sunset,
			/datum/time_of_day/dusk,
			/datum/time_of_day/midnight,
		)
		apply_time_of_day()

// Mirrors SSoutdoor_effects. The current step is the last one whose start has passed, and midnight
// when none has. When a step begins, the game animates from the previous step's color to the new
// one over min(1 hour, time until the next step), so the sun color here blends the same way based
// on how far into the step the slider is. A step with a tint list uses its first entry, which keeps
// the view deterministic instead of shimmering between bakes.
/datum/demir/vanderlin/proc/apply_time_of_day()
	var/day = 24 HOURS
	var/ticks = (tod_hours HOURS)
	var/count = length(tod_steps)

	var/index = count
	for(var/i in 1 to count)
		var/datum/time_of_day/candidate = tod_steps[i]
		if(ticks >= initial(candidate.start))
			index = i

	var/datum/time_of_day/current = tod_steps[index]
	var/datum/time_of_day/following = tod_steps[index == count ? 1 : index + 1]
	var/datum/time_of_day/previous = tod_steps[index == 1 ? count : index - 1]
	tod_step_name = initial(current.name)

	var/current_start = initial(current.start)
	var/following_start = initial(following.start)
	if(following_start <= current_start)
		following_start += day

	var/elapsed = ticks - current_start
	if(elapsed < 0)
		elapsed += day

	var/duration = min(1 HOURS, following_start - current_start)
	var/amount = 1
	if(duration > 0)
		amount = clamp(elapsed / duration, 0, 1)

	sun_color = demir_blend_hex(demir_step_tint(previous), demir_step_tint(current), amount)

/proc/demir_step_tint(step_path)
	var/datum/time_of_day/step = step_path
	var/tint = initial(step.color)
	if(islist(tint))
		var/list/tints = tint
		tint = length(tints) ? tints[1] : COLOR_WHITE
	return tint || COLOR_WHITE

// Channel 0, 1 or 2 of a "#rrggbb" string as 0 to 255.
/proc/demir_hex_channel(color, channel)
	var/value = 0
	for(var/offset in 0 to 1)
		var/code = text2ascii(color, 2 + (channel * 2) + offset)
		var/digit = code - 48
		if(code >= 97)
			digit = code - 87
		else if(code >= 65)
			digit = code - 55
		value = (value * 16) + digit
	return value

/proc/demir_blend_hex(from, next, amount)
	var/hexdigits = "0123456789abcdef"
	var/out = "#"
	for(var/channel in 0 to 2)
		var/a = demir_hex_channel(from, channel)
		var/b = demir_hex_channel(next, channel)
		var/v = clamp(round(a + ((b - a) * amount)), 0, 255)
		var/high = round(v / 16)
		var/low = v - (high * 16)
		out += copytext(hexdigits, high + 1, high + 2)
		out += copytext(hexdigits, low + 1, low + 2)
	return out

// Sunlight is the only thing that reads sun_color, so a slider move only has to redo lighting.
/datum/demir/vanderlin/proc/request_relight()
	demir_rebake(DEMIR_BAKE_LIGHT)

/datum/demir/vanderlin/ui(atom/target)
	imgui_set_next_window_size(280, 120)
	if(imgui_begin("Vanderlin"))
		ui_time_of_day()
	imgui_end()

/datum/demir/vanderlin/proc/ui_time_of_day()
	imgui_separator("Time of day")
	var/new_hours = imgui_slider("Hour", tod_hours, 0, 24)
	var/whole = round(new_hours)
	var/minutes = round((new_hours - whole) * 60)
	var/pad = minutes < 10 ? "0" : ""
	imgui_text("[whole]:[pad][minutes]  [tod_step_name]")
	if(new_hours != tod_hours)
		tod_hours = new_hours
		apply_time_of_day()
		request_relight()

/atom/proc/demir_prepare_light_state()
	return

/datum/demir/vanderlin/prepare(atom/target)
	target.demir_prepare_smoothing()
	target.demir_prepare_light_state()

/atom/proc/demir_bake_appearance()
	if(smoothing_flags & USES_SMOOTHING)
		smooth_icon()

/atom/proc/demir_finish_appearance()
	return

/atom/movable/demir_finish_appearance()
	demir_add_overlay_light()

// Water pipes bypass both generic smoothing and overlay lighting.
/obj/structure/water_pipe/demir_finish_appearance()
	return

/datum/demir/vanderlin/bake(atom/target)
	target.demir_bake_appearance()
	target.demir_finish_appearance()


// The day cycle picks one of the daytime tints at random. Noon is what a mapper wants to see, and
// a fixed choice keeps the view from shimmering between bakes. The profile now derives its sun
// color from the time of day slider, and this helper is no longer called from New().
/proc/demir_daylight_color()
	var/datum/time_of_day/daytime/noon = /datum/time_of_day/daytime
	var/tint = initial(noon.color)
	if(islist(tint))
		var/list/tints = tint
		return length(tints) ? tints[1] : COLOR_WHITE
	return tint || COLOR_WHITE

// `is_sky_visible()` walks the z stack through the mapping subsystem's level links and a
// transparency trait, neither of which the editor builds. Adjacent z levels stack instead, the way
// the water pipes above already assume.
/turf/proc/demir_sees_sky()
	if(pseudo_roof)
		return FALSE
	var/turf/above = locate(x, y, z + 1)
	if(above)
		return above.demir_sky_passes()
	var/area/here = get_area(src)
	return here && here.outdoors

/turf/proc/demir_sky_passes()
	return FALSE

/turf/open/openspace/demir_sky_passes()
	for(var/obj/structure/thing in src)
		if(thing.weatherproof)
			return FALSE
	return demir_sees_sky()

/atom/proc/demir_apply_light()
	if(light_system != STATIC_LIGHT || !light_on || !light_outer_range || !light_power)
		return
	demir_light_range = max(light_outer_range, MINIMUM_USEFUL_LIGHT_RANGE)
	demir_light_inner_range = light_inner_range
	demir_light_curve = light_falloff_curve
	// APPLY_CORNER squares the power and puts the sign back afterwards.
	demir_light_power = (light_power ** 2) * (light_power < 0 ? -1 : 1)
	demir_light_color = light_color
	// LUM_FALLOFF measures flat distance, with no pseudo z term under the root.
	demir_light_height = 0

// Sunlight spreads GLOBAL_LIGHT_RANGE tiles from every turf that can see the sky, and HARD_SUN is
// the -0.5 under the root. Corners keep the closest source rather than the sum, so this is a peak
// source. A lit turf reaches its own corners at full strength, which is what makes the outdoors
// read as daylight without an explicit border pass.
/turf/demir_apply_light()
	if(!demir_sees_sky())
		return ..()
	demir_light_range = 3
	demir_light_power = 1
	demir_light_height = -0.5
	var/datum/demir/vanderlin/profile = demir_profile()
	demir_light_color = profile.sun_color
	demir_light_peak = 1

/area/demir_apply_light()
	demir_fullbright = !dynamic_lighting

/datum/demir/vanderlin/light(atom/target)
	target.demir_apply_light()

#endif
