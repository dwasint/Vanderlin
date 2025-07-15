
// Advanced ore generation with geological realism
/proc/generate_ore_deposits(list/env_data, list/cave_map)
	world.log << "Generating ore deposits with geological accuracy..."
	var/list/ore_map = list()
	var/list/biome_map = env_data["biomes"]
	var/list/elevation_map = env_data["elevation"]

	// Initialize ore map
	for(var/x = 1; x <= MAP_SIZE; x++)
		ore_map["[x]"] = list()
		for(var/y = 1; y <= MAP_SIZE; y++)
			ore_map["[x]"]["[y]"] = null

	// Generate ore veins using realistic geological processes
	generate_ore_veins(ore_map, biome_map, elevation_map, cave_map)
	generate_ore_pockets(ore_map, biome_map, elevation_map)
	generate_rare_deposits(ore_map, biome_map, elevation_map)

	return ore_map

/proc/generate_ore_veins(list/ore_map, list/biome_map, list/elevation_map, list/cave_map)
	var/vein_count = 0
	var/max_veins = 200

	while(vein_count < max_veins)
		var/start_x = rand(1, MAP_SIZE)
		var/start_y = rand(1, MAP_SIZE)
		var/biome = biome_map["[start_x]"]["[start_y]"]

		// Determine ore type based on biome and elevation
		var/ore_type = determine_ore_type(biome, elevation_map["[start_x]"]["[start_y]"])
		if(!ore_type)
			continue

		// Generate vein path
		var/list/vein_path = generate_vein_path(start_x, start_y, biome)

		// Place ore along path
		for(var/list/coords in vein_path)
			var/x = coords[1]
			var/y = coords[2]
			if(x >= 1 && x <= MAP_SIZE && y >= 1 && y <= MAP_SIZE)
				if(!ore_map["[x]"]["[y]"] || get_ore_rarity(ore_type) > get_ore_rarity(ore_map["[x]"]["[y]"]))
					ore_map["[x]"]["[y]"] = ore_type

		vein_count++

/proc/generate_vein_path(start_x, start_y, biome)
	var/list/path = list()
	var/x = start_x
	var/y = start_y
	var/length = rand(5, 20)

	if(biome == BIOME_MOUNTAIN)
		length = rand(15, 40)

	var/direction = rand(0, 360)

	for(var/i = 1; i <= length; i++)
		path += list(list(round(x), round(y)))

		// Add some randomness to vein direction
		direction += rand(-30, 30)
		var/step_size = rand(1, 3)

		x += cos(direction) * step_size
		y += sin(direction) * step_size

		// Boundary check
		if(x < 1 || x > MAP_SIZE || y < 1 || y > MAP_SIZE)
			break

	return path

/proc/determine_ore_type(biome, elevation)
	switch(biome)
		if(BIOME_MOUNTAIN)
			if(elevation > 0.8)
				return pick("iron", "copper", "silver", "gold")
			else
				return pick("iron", "copper", "silver", "gold", "tin", "cinnabar")

		if(BIOME_SWAMP)
			return pick("iron", "copper", "tin", "coal", "sulfur")

		if(BIOME_FOREST)
			return pick("iron", "copper", "coal", "clay")

		else
			return pick("iron", "copper", "coal")

/proc/get_ore_rarity(ore_type)
	switch(ore_type)
		if("mithril", "adamantine")
			return ORE_LEGENDARY
		if("gold", "silver")
			return ORE_RARE
		if("tin", "lead", "sulfur")
			return ORE_UNCOMMON
		else
			return ORE_COMMON

/proc/generate_ore_pockets(list/ore_map, list/biome_map, list/elevation_map)
	// Generate scattered ore pockets
	for(var/i = 1; i <= 500; i++)
		var/x = rand(1, MAP_SIZE)
		var/y = rand(1, MAP_SIZE)
		var/biome = biome_map["[x]"]["[y]"]
		var/elevation = elevation_map["[x]"]["[y]"]

		var/ore_type = determine_ore_type(biome, elevation)
		if(!ore_type)
			continue

		var/pocket_size = rand(2, 6)

		for(var/j = 1; j <= pocket_size; j++)
			var/px = x + rand(-2, 2)
			var/py = y + rand(-2, 2)

			if(px >= 1 && px <= MAP_SIZE && py >= 1 && py <= MAP_SIZE)
				if(!ore_map["[px]"]["[py]"])
					ore_map["[px]"]["[py]"] = ore_type

/proc/generate_rare_deposits(list/ore_map, list/biome_map, list/elevation_map)
	// Generate rare magical deposits
	for(var/i = 1; i <= 20; i++)
		var/x = rand(1, MAP_SIZE)
		var/y = rand(1, MAP_SIZE)
		var/biome = biome_map["[x]"]["[y]"]
		var/elevation = elevation_map["[x]"]["[y]"]

		if(biome == BIOME_MOUNTAIN && elevation > 0.7)
			if(prob(30))
				ore_map["[x]"]["[y]"] = pick("mithril", "adamantine", "crystal")
