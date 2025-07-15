GLOBAL_LIST_EMPTY(spawned_features)
GLOBAL_LIST_EMPTY(flora_blocked_tiles)

/proc/place_comprehensive_flora(list/env_data)
	world.log << "Placing comprehensive flora system..."
	var/list/biome_map = env_data["biomes"]
	var/list/temperature_map = env_data["temperature"]
	var/list/moisture_map = env_data["moisture"]
	var/list/elevation_map = env_data["elevation"]

	for(var/x = 1; x <= MAP_SIZE; x++)
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/checked_z = Z_GROUND
			var/turf/T = locate(x, y, checked_z)
			while(T && T?.density && checked_z != Z_HIGH_AIR + 1)
				if(!T || T.density)
					checked_z++
					T = locate(x, y, checked_z)
			if(!T || T.density)
				continue

			var/biome = biome_map["[x]"]["[y]"]
			var/temp = temperature_map["[x]"]["[y]"]
			var/moisture = moisture_map["[x]"]["[y]"]
			var/elevation = elevation_map["[x]"]["[y]"]

			place_biome_specific_flora(T, biome, temp, moisture, elevation, x, y, env_data)

/proc/place_biome_specific_flora(turf/T, biome, temp, moisture, elevation, x, y, list/env_data)
	if(is_flora_blocked(x, y, T.z))
		return

	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(!biome_datum)
		return

	var/flora_density = biome_datum.get_flora_density(temp, moisture, elevation)

	if(!prob(flora_density * 100))
		return

	// Check for rivers first
	generate_river_terrain(T, env_data, x, y)

	var/list/river_map = env_data["rivers"]
	if(river_map && river_map["[x]"]["[y]"])
		return // TODO: add water based ecosystem

	biome_datum.place_ecosystem(T, temp, moisture, elevation, x, y)

// Comprehensive terrain generation for all z-levels
/proc/generate_comprehensive_terrain(list/env_data, list/cave_map, list/ore_map)
	world.log << "Generating comprehensive terrain across all z-levels with verticality..."

	var/list/biome_map = env_data["biomes"]
	var/list/temperature_map = env_data["temperature"]
	var/list/moisture_map = env_data["moisture"]
	var/list/elevation_map = env_data["elevation"]

	// Generate height map for vertical features
	var/list/height_map = generate_height_map(biome_map, elevation_map)

	// Store height map in env_data for later use
	env_data["height"] = height_map

	// Generate underground level first
	generate_underground_terrain(biome_map, elevation_map, cave_map, ore_map)

	// Generate all z-levels with proper height support
	for(var/x = 1; x <= MAP_SIZE; x++)
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/terrain_height = height_map["[x]"]["[y]"]
			var/biome = biome_map["[x]"]["[y]"]
			var/temperature = temperature_map["[x]"]["[y]"]
			var/moisture = moisture_map["[x]"]["[y]"]
			var/elevation = elevation_map["[x]"]["[y]"]

			// Generate terrain for each z-level
			generate_vertical_terrain_column(x, y, terrain_height, biome, temperature, moisture, elevation, env_data)

	// Generate special features after basic terrain
	generate_special_terrain_features(biome_map, elevation_map)

/proc/generate_vertical_terrain_column(x, y, height, biome, temperature, moisture, elevation, list/env_data)
	// Generate terrain column from ground up to specified height

	// Ground level (Z_GROUND)
	var/turf/ground_turf = locate(x, y, Z_GROUND)
	if(ground_turf)
		if(height > 0)
			// If there's height above, this becomes a mineral wall base
			generate_mineral_wall_base(ground_turf, biome, elevation, x, y, env_data)
		else
			// Normal ground terrain
			generate_detailed_ground_tile(ground_turf, biome, temperature, moisture, elevation, x, y, env_data)

	// Air levels (Z_AIR and above)
	for(var/z = Z_AIR; z <= Z_HIGH_AIR; z++)
		var/turf/air_turf = locate(x, y, z)
		if(!air_turf) continue

		var/relative_height = z - Z_GROUND  // Height relative to ground level

		if(relative_height <= height)
			// This level should have terrain
			generate_elevated_terrain(air_turf, biome, temperature, moisture, elevation, relative_height, x, y, env_data)
		else
			// This level should be open space
			air_turf.ChangeTurf(/turf/open/transparent/openspace, flags = CHANGETURF_SKIP)
			add_air_features(air_turf, biome, elevation, z, x, y)


/proc/generate_mineral_wall_base(turf/T, biome, elevation, x, y, list/env_data)
	// Check for rivers first - rivers override mineral walls
	generate_river_terrain(T, env_data, x, y)

	var/list/river_map = env_data["rivers"]
	if(river_map && river_map["[x]"]["[y]"])
		return // Skip mineral wall generation for river tiles

	// Use biome datum for mineral wall generation
	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(biome_datum)
		biome_datum.generate_structural_terrain(T, elevation, 1, x, y)

/proc/generate_elevated_terrain(turf/T, biome, temperature, moisture, elevation, relative_height, x, y, list/env_data)
	// Generate terrain for elevated levels

	// Check if this is the top level of the terrain column
	var/list/height_map = env_data["height"]
	var/max_height = height_map["[x]"]["[y]"]
	var/is_top_level = (relative_height == max_height)

	if(is_top_level)
		// Top level gets normal terrain based on biome
		generate_elevated_top_terrain(T, biome, temperature, moisture, elevation, relative_height, x, y, env_data)
	else
		// Lower levels get structural terrain (walls, cliffs)
		generate_elevated_structural_terrain(T, biome, elevation, relative_height, x, y)

/proc/generate_elevated_top_terrain(turf/T, biome, temperature, moisture, elevation, relative_height, x, y, list/env_data)
	// Use biome datum for elevated terrain generation
	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(biome_datum)
		biome_datum.generate_elevated_terrain(T, temperature, moisture, elevation, relative_height, x, y)

/proc/generate_elevated_structural_terrain(turf/T, biome, elevation, relative_height, x, y)
	// Use biome datum for structural terrain generation
	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(biome_datum)
		biome_datum.generate_structural_terrain(T, elevation, relative_height, x, y)

/proc/generate_ground_terrain_with_verticality(list/biome_map, list/temperature_map, list/moisture_map, list/elevation_map, list/height_map, list/env_data)
	world.log << "Generating ground terrain with vertical features..."

	for(var/x = 1; x <= MAP_SIZE; x++)
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/turf/T = locate(x, y, Z_GROUND)
			if(!T) continue

			var/biome = biome_map["[x]"]["[y]"]
			var/temperature = temperature_map["[x]"]["[y]"]
			var/moisture = moisture_map["[x]"]["[y]"]
			var/elevation = elevation_map["[x]"]["[y]"]
			var/height = height_map["[x]"]["[y]"]


			// Check if this should be a vertical wall
			if(height > Z_GROUND)
				generate_vertical_wall_base(T, biome, elevation, x, y, env_data)
			else
				generate_detailed_ground_tile(T, biome, temperature, moisture, elevation, x, y, env_data)

/proc/generate_vertical_wall_base(turf/T, biome, elevation, x, y, list/env_data)
	// Check for rivers first
	generate_river_terrain(T, env_data, x, y)

	var/list/river_map = env_data["rivers"]
	if(river_map && river_map["[x]"]["[y]"])
		return // Skip other terrain generation for river tiles

	// Use biome datum for vertical wall base generation
	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(biome_datum)
		biome_datum.generate_structural_terrain(T, elevation, 1, x, y)

/proc/generate_air_terrain_with_verticality(list/biome_map, list/elevation_map, list/height_map)
	world.log << "Generating air levels with vertical terrain..."

	for(var/z = Z_AIR; z <= Z_HIGH_AIR; z++)
		for(var/x = 1; x <= MAP_SIZE; x++)
			for(var/y = 1; y <= MAP_SIZE; y++)
				var/turf/T = locate(x, y, z)
				if(!T) continue

				var/biome = biome_map["[x]"]["[y]"]
				var/elevation = elevation_map["[x]"]["[y]"]
				var/height = height_map["[x]"]["[y]"]

				// Check if terrain should extend to this height
				if(height >= z)
					generate_vertical_terrain_level(T, biome, elevation, z, x, y)
				else
					// Default to open space
					T.ChangeTurf(/turf/open/transparent/openspace, flags = CHANGETURF_SKIP)
					add_air_features(T, biome, elevation, z, x, y)

/proc/generate_vertical_terrain_level(turf/T, biome, elevation, z, x, y)
	// Use biome datum for vertical terrain level generation
	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(biome_datum)
		// Calculate relative height for the biome datum
		var/relative_height = z - Z_GROUND
		biome_datum.generate_structural_terrain(T, elevation, relative_height, x, y)

/proc/generate_mountain_vertical_terrain(turf/T, elevation, z, x, y)
	// Mountain terrain at different heights
	if(z == Z_HIGH_AIR)
		// High peaks - mostly bare rock and snow
		if(elevation > 0.8)
			T.ChangeTurf(/turf/open/floor/naturalstone, flags = CHANGETURF_SKIP)
		else
			T.ChangeTurf(/turf/open/floor/cobblerock, flags = CHANGETURF_SKIP)

	else if(z == Z_AIR)
		// Mid-level mountain terrain
		if(elevation > 0.7)
			T.ChangeTurf(/turf/open/floor/naturalstone, flags = CHANGETURF_SKIP)
		else
			T.ChangeTurf(/turf/open/floor/cobblerock, flags = CHANGETURF_SKIP)


/proc/generate_forest_vertical_terrain(turf/T, elevation, z, x, y)
	// Forest terrain at height (hills, cliffs)
	if(z == Z_AIR)
		// Forest hills - grass and trees
		if(elevation > 0.8)
			T.ChangeTurf(/turf/open/floor/grass/cold, flags = CHANGETURF_SKIP)
		else
			T.ChangeTurf(/turf/open/floor/grass, flags = CHANGETURF_SKIP)

/proc/generate_swamp_vertical_terrain(turf/T, elevation, z, x, y)
	// Rare swamp elevated areas
	if(z == Z_AIR)
		T.ChangeTurf(/turf/open/floor/dirt, flags = CHANGETURF_SKIP)


/proc/add_cave_features(turf/T, biome, elevation, x, y)

	// Underground water
	if(biome == BIOME_SWAMP && prob(10))
		new /turf/open/water(T)

	// Crystal formations in mountains
	if(biome == BIOME_MOUNTAIN && elevation > 0.7 && prob(2))
		new /obj/item/mana_battery/mana_crystal/standard(T)

/proc/generate_ground_terrain(list/biome_map, list/temperature_map, list/moisture_map, list/elevation_map, list/env_data)
	world.log << "Generating detailed ground terrain..."

	for(var/x = 1; x <= MAP_SIZE; x++)
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/turf/T = locate(x, y, Z_GROUND)
			if(!T) continue

			var/biome = biome_map["[x]"]["[y]"]
			var/temperature = temperature_map["[x]"]["[y]"]
			var/moisture = moisture_map["[x]"]["[y]"]
			var/elevation = elevation_map["[x]"]["[y]"]

			generate_detailed_ground_tile(T, biome, temperature, moisture, elevation, x, y, env_data)


/proc/generate_detailed_ground_tile(turf/T, biome, temperature, moisture, elevation, x, y, list/env_data)
	// Check for rivers first
	generate_river_terrain(T, env_data, x, y)

	// Only generate other terrain if not a river
	var/list/river_map = env_data["rivers"]
	if(river_map && river_map["[x]"]["[y]"])
		return // Skip other terrain generation for river tiles

	// Use biome datum for ground terrain generation
	var/datum/biome/biome_datum = get_biome_datum(biome)
	if(biome_datum)
		biome_datum.generate_ground_terrain(T, temperature, moisture, elevation, x, y)

// Add a post-processing terrain smoothing step
/proc/smooth_terrain_post_process()
	world.log << "Applying enhanced terrain smoothing..."

	// Apply 4 passes of smoothing for very smooth terrain
	for(var/pass = 1; pass <= 4; pass++)
		for(var/x = 2; x <= MAP_SIZE-1; x++)
			for(var/y = 2; y <= MAP_SIZE-1; y++)
				var/turf/T = locate(x, y, Z_GROUND)
				if(!T) continue

				smooth_terrain_tile_enhanced(T, x, y)

/proc/smooth_terrain_tile_enhanced(turf/T, x, y)
	var/list/terrain_counts = list()
	var/total_neighbors = 0

	// Check 3x3 neighborhood
	for(var/dx = -1; dx <= 1; dx++)
		for(var/dy = -1; dy <= 1; dy++)
			var/nx = x + dx
			var/ny = y + dy
			if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
				var/turf/neighbor = locate(nx, ny, Z_GROUND)
				if(neighbor)
					var/terrain_type = neighbor.type
					terrain_counts["[terrain_type]"] = (terrain_counts["[terrain_type]"] || 0) + 1
					total_neighbors++

	// Find most common terrain type
	var/dominant_terrain = T.type
	var/max_count = 0

	for(var/terrain_type in terrain_counts)
		var/count = terrain_counts["[terrain_type]"]
		if(count > max_count)
			max_count = count
			dominant_terrain = text2path(terrain_type)

	// Change if there's a clear majority (5+ out of 9)
	if(max_count >= 5 && T.type != dominant_terrain)
		T.ChangeTurf(dominant_terrain, flags = CHANGETURF_SKIP)

/proc/add_forest_details(turf/T, temperature, moisture, elevation)
	return

/proc/add_swamp_details(turf/T, temperature, moisture, elevation)
	// Swamp details
	if(prob(12))
		new /obj/item/grown/log(T)


/proc/add_mountain_details(turf/T, temperature, moisture, elevation)
	// Mountain details
	if(prob(15))
		new /obj/structure/roguerock(T)

/proc/generate_air_terrain(list/biome_map, list/elevation_map)
	world.log << "Generating air levels..."

	for(var/z = Z_AIR; z <= Z_HIGH_AIR; z++)
		for(var/x = 1; x <= MAP_SIZE; x++)
			for(var/y = 1; y <= MAP_SIZE; y++)
				var/turf/T = locate(x, y, z)
				if(!T) continue

				var/biome = biome_map["[x]"]["[y]"]
				var/elevation = elevation_map["[x]"]["[y]"]

				// Default to sky
				T.ChangeTurf(/turf/open/transparent/openspace, flags = CHANGETURF_SKIP)

				// Add floating elements
				add_air_features(T, biome, elevation, z, x, y)

/proc/add_air_features(turf/T, biome, elevation, z, x, y)
	return

/proc/generate_complete_world()
	world.log << "=== Starting Complete World Generation with Verticality ==="

	// Initialize seed
	init_world_seed()

	// Step 1: Generate environmental data
	world.log << "Step 1: Generating environmental maps..."
	var/list/env_data = generate_biome_map()

	// Step 2: Generate cave systems
	world.log << "Step 2: Generating cave systems..."
	var/list/cave_map = generate_cave_system(env_data)

	// Step 2.5: Generate river systems
	world.log << "Step 2.5: Generating river systems..."
	var/list/river_map = generate_river_system(env_data)

	// Step 3: Generate ore deposits
	world.log << "Step 3: Generating ore deposits..."
	var/list/ore_map = generate_ore_deposits(env_data, cave_map)

	// Step 4: Generate all terrain with verticality
	world.log << "Step 4: Generating comprehensive terrain with verticality..."
	generate_comprehensive_terrain(env_data, cave_map, ore_map)

	// Step 4.5: Apply terrain smoothing
	world.log << "Step 4.5: Applying terrain smoothing..."
	smooth_terrain_post_process()

	// Step 5: Place features
	world.log << "Step 5: Spawning world features..."
	spawn_world_features(env_data)

	// Step 6: Place flora
	world.log << "Step 5: Placing comprehensive flora..."
	place_comprehensive_flora(env_data)

	// Step 7: Spawn creatures
	world.log << "Step 6: Spawning ecological creatures..."
	spawn_ecological_creatures(env_data)

	world.log << "=== World Generation Complete ==="
	world.log << "Generated [MAP_SIZE]x[MAP_SIZE]x4 world with realistic biomes, caves, rivers, vertical terrain, and ecosystems."
