/obj/structure/water_pipe
	name = "water pipe"
	desc = ""
	icon_state = "base"
	icon = 'icons/roguetown/misc/pipes.dmi'
	density = FALSE
	layer = TABLE_LAYER
	plane = GAME_PLANE
	damage_deflection = 5
	blade_dulling = DULLING_BASHCHOP
	attacked_sound = list('sound/combat/hits/onmetal/grille (1).ogg', 'sound/combat/hits/onmetal/grille (2).ogg', 'sound/combat/hits/onmetal/grille (3).ogg')
	smeltresult = /obj/item/ingot/bronze

	var/water_pressure
	var/datum/reagent/carrying_reagent
	var/list/connected = list("2" = 0, "1" = 0, "8" = 0, "4" = 0)

/obj/structure/water_pipe/Initialize()
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/water_pipe/pipe in cardinal_turf)
			if(!istype(pipe))
				return
			set_connection(get_dir(src, pipe))
			pipe.set_connection(get_dir(pipe, src))
			pipe.update_overlays()
	update_overlays()
	START_PROCESSING(SSobj, src)

/obj/structure/water_pipe/Destroy()
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/water_pipe/pipe in cardinal_turf)
			if(!istype(pipe))
				return
			pipe.unset_connection(get_dir(pipe, src))
			pipe.update_overlays()

/obj/structure/water_pipe/proc/set_connection(dir)
	connected["[dir]"] = 1
	update_overlays()

/obj/structure/water_pipe/proc/unset_connection(dir)
	connected["[dir]"] = 0
	update_overlays()

/obj/structure/water_pipe/update_overlays()
	. = ..()
	var/new_overlay = ""
	for(var/i in connected)
		if(connected[i])
			new_overlay += i
	icon_state = "[new_overlay]"
	if(!new_overlay)
		icon_state = "base"
