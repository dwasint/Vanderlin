SUBSYSTEM_DEF(dungeon_generator)
	name = "Matthios's Creation"

	var/list/parent_types = list()

	var/list/created_types = list()

/datum/controller/subsystem/dungeon_generator/proc/find_soulmate(direction, turf/creator, obj/effect/dungeon_directional_helper/looking_for_love)
	switch(direction)
		if(NORTH)
			direction = SOUTH
		if(SOUTH)
			direction = NORTH
		if(EAST)
			direction = WEST
		if(WEST)
			direction = EAST
	creator = get_step(creator, direction)

	if(!length(parent_types))
		for(var/datum/map_template/dungeon/path as anything in subtypesof(/datum/map_template/dungeon))
			if(!is_abstract(path))
				continue
			parent_types += path
			parent_types[path] = initial(path.type_weight)

	if(!length(created_types))
		for(var/path in subtypesof(/datum/map_template/dungeon))
			if(is_abstract(path))
				continue
			created_types += new path

	var/picked_type = pickweight(parent_types)
	var/picking = TRUE

	var/list/true_list = created_types.Copy()
	while(picking)
		if(!length(true_list))
			return
		var/datum/map_template/dungeon/template = pickweight(true_list)
		true_list -= template
		if(is_abstract(template))
			continue
		if(!is_type_in_list(template, subtypesof(picked_type)))
			continue
		var/turf/spawn_turf
		var/turf/true_spawn
		switch(direction)
			if(NORTH)
				if(!template.north_offset)
					continue
				if(creator.x - template.north_offset < 0)
					continue
				spawn_turf = get_ranged_target_turf(creator, WEST, template.north_offset)
				true_spawn = get_ranged_target_turf(spawn_turf, SOUTH, template.height)
				if(true_spawn.x + template.width > world.maxx)
					continue
				if(true_spawn.y + template.height > world.maxy)
					continue
				if(!template.load(true_spawn))
					continue

			if(SOUTH)
				if(!template.south_offset)
					continue
				if(creator.x - template.south_offset < 0)
					continue
				true_spawn = get_ranged_target_turf(creator, WEST, template.south_offset)
				if(true_spawn.x + template.width > world.maxx)
					continue
				if(true_spawn.y + template.height > world.maxy)
					continue
				if(!template.load(true_spawn))
					continue

			if(EAST)
				if(!template.east_offset)
					continue
				if(creator.y - template.east_offset < 0)
					continue
				spawn_turf = get_ranged_target_turf(creator, SOUTH, template.east_offset)
				true_spawn = get_ranged_target_turf(creator, WEST, template.width)
				if(true_spawn.x + template.width > world.maxx)
					continue
				if(true_spawn.y + template.height > world.maxy)
					continue
				if(!template.load(true_spawn))
					continue

			if(WEST)
				if(!template.west_offset)
					continue
				if(creator.y - template.west_offset < 0)
					continue
				true_spawn = get_ranged_target_turf(creator, SOUTH, template.west_offset)
				if(true_spawn.x + template.width > world.maxx)
					continue
				if(true_spawn.y + template.height > world.maxy)
					continue
				if(!template.load(true_spawn))
					continue
		picking = FALSE
