/obj/structure/water_pump
	name = "water pump"

	stress_use = 64
	stress_multiplier = 30
	cog_type = COG_SMALL

	var/turf/open/water/pumping_from
	var/pumping_volume = 0

/obj/structure/water_pump/Initialize()
	. = ..()
	try_find_rotation_group()

/obj/structure/water_pump/try_find_rotation_group()
	for(var/direction in GLOB.cardinals)
		if(direction == dir)
			continue
		if(direction == GLOB.reverse_dir[dir])
			continue
		var/turf/step_forward = get_step(src, direction)
		for(var/obj/structure/structure in step_forward.contents)
			if(structure.rotation_data)
				if(rotation_data)
					rotation_data.try_merge_groups(src, structure.rotation_data)
				else
					structure.rotation_data.add_child(src)
					structure.rotation_data.add_stress_user(src)
