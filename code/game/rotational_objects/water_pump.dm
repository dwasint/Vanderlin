/obj/structure/water_pump
	name = "water pump"
	rotation_structure = TRUE
	stress_use = 64
	icon_state = "p1"
	icon = 'icons/obj/rotation_machines.dmi'
	layer = 5


	var/turf/open/water/pumping_from
	var/pumping_volume = 0
	var/last_provided_pressure = 0
	var/mutable_appearance/water_spray

/obj/structure/water_pump/find_rotation_network()

	for(var/direction in GLOB.cardinals)
		var/turf/step_back = get_step(src, direction)
		for(var/obj/structure/structure in step_back.contents)
			if(direction == dir || direction == GLOB.reverse_dir[dir])
				continue
			if(!istype(structure, /obj/structure/rotation_piece/cog))
				continue
			if(structure.rotation_network)
				if(rotation_network)
					if(!structure.try_network_merge(src))
						rotation_break()
				else
					if(!structure.try_connect(src))
						rotation_break()

	if(!rotation_network)
		rotation_network = new
		rotation_network.add_connection(src)

/obj/structure/water_pump/return_surrounding_rotation(datum/rotation_network/network)
	var/list/surrounding = list()

	for(var/direction in GLOB.cardinals)
		var/turf/step_back = get_step(src, direction)
		for(var/obj/structure/structure in step_back.contents)
			if(direction == dir || direction == GLOB.reverse_dir[dir])
				continue
			if(!istype(structure, /obj/structure/rotation_piece/cog))
				continue
			if(!(structure in network.connected))
				continue
			surrounding |= structure
	return surrounding

/obj/structure/water_pump/set_rotations_per_minute(speed)
	set_stress_use(64 * (speed / 8))
	if(speed > 0)
		START_PROCESSING(SSobj, src)
	else
		var/turf/open/pipe_turf = get_step(src, dir)
		var/obj/structure/water_pipe/pipe  = locate(/obj/structure/water_pipe) in pipe_turf
		if(pipe)
			pipe.remove_provider(pumping_from.water_reagent, last_provided_pressure)
		STOP_PROCESSING(SSobj, src)
		pumping_from = null
		stop_spray()
	. = ..()

/obj/structure/water_pump/can_connect(obj/structure/connector)
	if(connector.rotation_direction && connector.rotation_direction != rotation_direction)
		if(!istype(connector, /obj/structure/rotation_piece/cog) && !istype(connector, /obj/structure/water_pump))
			if(connector.rotations_per_minute && rotations_per_minute)
				return FALSE
	return TRUE

/obj/structure/water_pump/update_animation_effect()
	if(!rotation_network || rotation_network?.overstressed || !rotations_per_minute)
		animate(src, icon_state = "p1", time = 1)
		return
	var/frame_stage = 1 / ((rotations_per_minute / 60) * 4)
	if(rotation_direction == WEST)
		animate(src, icon_state = "p1", time = frame_stage, loop=-1)
		animate(icon_state = "p2", time = frame_stage)
		animate(icon_state = "p3", time = frame_stage)
		animate(icon_state = "p4", time = frame_stage)
	else
		animate(src, icon_state = "p4", time = frame_stage, loop=-1)
		animate(icon_state = "p3", time = frame_stage)
		animate(icon_state = "p2", time = frame_stage)
		animate(icon_state = "p1", time = frame_stage)

/obj/structure/water_pump/process()
	if(!rotations_per_minute)
		return
	if(!pumping_from)
		var/turf/open/water/water = get_step(src, GLOB.reverse_dir[dir])
		if(!istype(water))
			return
		pumping_from = water

	var/turf/open/pipe_turf = get_step(src, dir)
	if(!locate(/obj/structure/water_pipe) in pipe_turf)
		spray_water()
		return

	stop_spray()
	var/obj/structure/water_pipe/pipe  = locate(/obj/structure/water_pipe) in pipe_turf


	var/new_pressure = rotations_per_minute
	if(last_provided_pressure != new_pressure)
		pipe.make_provider(pumping_from.water_reagent, new_pressure)
	pumping_from.adjust_originate_watervolume(-2)

/obj/structure/water_pump/proc/spray_water()
	if(!water_spray)
		water_spray = mutable_appearance(icon, "water_spray")
		water_spray.pixel_y = -32
	cut_overlay(water_spray)
	water_spray.color = initial(pumping_from.water_reagent.color)
	add_overlay(water_spray)

/obj/structure/water_pump/proc/stop_spray()
	cut_overlay(water_spray)
