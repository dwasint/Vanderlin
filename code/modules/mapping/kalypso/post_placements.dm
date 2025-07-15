/proc/generate_special_terrain_features(list/biome_map, list/elevation_map)
	world.log << "Generating special terrain features..."

	// Generate special locations
	generate_ancient_ruins(biome_map, elevation_map)
	generate_natural_landmarks(biome_map, elevation_map)
	generate_resource_hotspots(biome_map, elevation_map)

/proc/generate_ancient_ruins(list/biome_map, list/elevation_map)
	var/ruins_count = rand(5, 12)

	for(var/i = 1; i <= ruins_count; i++)
		var/x = rand(50, MAP_SIZE-50)
		var/y = rand(50, MAP_SIZE-50)
		var/biome = biome_map["[x]"]["[y]"]
		var/elevation = elevation_map["[x]"]["[y]"]

		var/ruin_type = determine_ruin_type(biome, elevation)
		if(ruin_type)
			generate_ruin_structure(x, y, ruin_type, biome)

/proc/determine_ruin_type(biome, elevation)
	switch(biome)
		if(BIOME_FOREST)
			return pick("elven_ruins", "druid_circle", "abandoned_village")
		if(BIOME_SWAMP)
			return pick("sunken_temple", "witch_hut", "cursed_shrine")
		if(BIOME_MOUNTAIN)
			if(elevation > 0.7)
				return pick("dwarven_fortress", "ancient_observatory", "dragon_lair")
			else
				return pick("mountain_shrine", "hermit_cave", "mining_camp")

	return null

/proc/generate_ruin_structure(center_x, center_y, ruin_type, biome)
	var/structure_size = rand(5, 15)

	for(var/dx = -structure_size; dx <= structure_size; dx++)
		for(var/dy = -structure_size; dy <= structure_size; dy++)
			var/x = center_x + dx
			var/y = center_y + dy

			if(x < 1 || x > MAP_SIZE || y < 1 || y > MAP_SIZE)
				continue

			var/distance = sqrt(dx*dx + dy*dy)
			if(distance > structure_size)
				continue

			place_ruin_element(x, y, ruin_type, biome, distance, structure_size)

/proc/place_ruin_element(x, y, ruin_type, biome, distance, max_distance)
	var/turf/ground_turf = locate(x, y, Z_GROUND)
	var/turf/underground_turf = locate(x, y, Z_UNDERGROUND)

	if(!ground_turf || !underground_turf)
		return

	var/placement_chance = 100 * (1 - distance / max_distance)

	if(prob(placement_chance))
		var/structure_type = select_ruin_structure(ruin_type, distance, max_distance)
		if(structure_type)
			new structure_type(ground_turf)

		// Underground components
		if(prob(30))
			var/underground_type = select_underground_ruin_structure(ruin_type)
			if(underground_type)
				new underground_type(underground_turf)

/proc/select_ruin_structure(ruin_type, distance, max_distance)
	return null

/proc/select_underground_ruin_structure(ruin_type)
	return null

/proc/generate_natural_landmarks(list/biome_map, list/elevation_map)
	var/landmark_count = rand(8, 15)

	for(var/i = 1; i <= landmark_count; i++)
		var/x = rand(1, MAP_SIZE)
		var/y = rand(1, MAP_SIZE)
		var/biome = biome_map["[x]"]["[y]"]
		var/elevation = elevation_map["[x]"]["[y]"]

		var/landmark_type = determine_landmark_type(biome, elevation)
		if(landmark_type)
			generate_landmark(x, y, landmark_type, biome, elevation)

/proc/determine_landmark_type(biome, elevation)
	switch(biome)
		if(BIOME_FOREST)
			return pick("giant_tree", "forest_clearing", "fairy_ring")
		if(BIOME_SWAMP)
			return pick("bog_island", "geyser", "tar_pit")
		if(BIOME_MOUNTAIN)
			if(elevation > 0.8)
				return pick("peak_summit", "crystal_cave", "mountain_pass")
			else
				return pick("cliff_face", "mountain_spring", "avalanche_zone")

	return null

/proc/generate_landmark(center_x, center_y, landmark_type, biome, elevation)
	var/landmark_size = rand(3, 8)

	for(var/dx = -landmark_size; dx <= landmark_size; dx++)
		for(var/dy = -landmark_size; dy <= landmark_size; dy++)
			var/x = center_x + dx
			var/y = center_y + dy

			if(x < 1 || x > MAP_SIZE || y < 1 || y > MAP_SIZE)
				continue

			var/distance = sqrt(dx*dx + dy*dy)
			if(distance > landmark_size)
				continue

			place_landmark_element(x, y, landmark_type, distance, landmark_size)

/proc/place_landmark_element(x, y, landmark_type, distance, max_distance)
	var/turf/T = locate(x, y, Z_GROUND)
	if(!T)
		return

/proc/generate_resource_hotspots(list/biome_map, list/elevation_map)
	var/hotspot_count = rand(10, 20)

	for(var/i = 1; i <= hotspot_count; i++)
		var/x = rand(1, MAP_SIZE)
		var/y = rand(1, MAP_SIZE)
		var/biome = biome_map["[x]"]["[y]"]
		var/elevation = elevation_map["[x]"]["[y]"]

		var/hotspot_type = determine_hotspot_type(biome, elevation)
		if(hotspot_type)
			generate_resource_hotspot(x, y, hotspot_type, biome)

/proc/determine_hotspot_type(biome, elevation)
	switch(biome)
		if(BIOME_FOREST)
			return pick("herb_garden", "berry_patch", "mushroom_grove")
		if(BIOME_SWAMP)
			return pick("rare_herb_bog", "medicinal_spring", "poison_garden")
		if(BIOME_MOUNTAIN)
			return pick("gem_deposit", "rare_metal_vein", "crystal_formation")

	return null

/proc/generate_resource_hotspot(center_x, center_y, hotspot_type, biome)
	var/hotspot_size = rand(4, 10)

	for(var/dx = -hotspot_size; dx <= hotspot_size; dx++)
		for(var/dy = -hotspot_size; dy <= hotspot_size; dy++)
			var/x = center_x + dx
			var/y = center_y + dy

			if(x < 1 || x > MAP_SIZE || y < 1 || y > MAP_SIZE)
				continue

			var/distance = sqrt(dx*dx + dy*dy)
			if(distance > hotspot_size)
				continue

			place_hotspot_resource(x, y, hotspot_type, distance, hotspot_size)

/proc/place_hotspot_resource(x, y, hotspot_type, distance, max_distance)
	var/turf/T = locate(x, y, Z_GROUND)
	if(!T || T.density)
		return

	var/resource_density = 100 * (1 - distance / max_distance)

	if(prob(resource_density))
		var/resource_type = select_hotspot_resource(hotspot_type)
		if(resource_type)
			new resource_type(T)

/proc/select_hotspot_resource(hotspot_type)
	switch(hotspot_type)
		if("herb_garden")
			return pick(/obj/structure/flora/grass/herb/random)
		if("berry_patch")
			return pick(/obj/structure/wild_plant/random)
		if("gem_deposit")
			return pick(/obj/item/gem)
		if("rare_metal_vein")
			return pick(/obj/item/natural/rock/gold, /obj/item/natural/rock/silver, /obj/item/natural/rock/gold)

	return null
