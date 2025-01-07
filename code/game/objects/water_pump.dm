/obj/structure/water_pump
	name = "water pump"
	rotation_structure = TRUE
	stress_use = 64


	var/turf/open/water/pumping_from
	var/pumping_volume = 0

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
	. = ..()
