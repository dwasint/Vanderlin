/proc/generate_biome_map()
	world.log << "Generating harmonious biome map with modular scoring..."
	var/list/biome_map = list()
	var/list/temperature_map = list()
	var/list/moisture_map = list()
	var/list/elevation_map = list()

	// Generate environmental maps (keeping your existing noise generation)
	for(var/x = 1; x <= MAP_SIZE; x++)
		biome_map["[x]"] = list()
		temperature_map["[x]"] = list()
		moisture_map["[x]"] = list()
		elevation_map["[x]"] = list()

		for(var/y = 1; y <= MAP_SIZE; y++)
			// Temperature - MUCH larger scale for continental patterns
			var/base_temp = 0.5 + (y - MAP_SIZE/2) / MAP_SIZE * 0.3
			var/temp_noise = perlin_noise(x * 0.003, y * 0.003, 123) * 0.4
			temp_noise += perlin_noise(x * 0.008, y * 0.008, 124) * 0.1
			temperature_map["[x]"]["[y]"] = base_temp + temp_noise

			// Moisture - EXTREMELY large scale for continent-like patterns
			var/moisture = perlin_noise(x * 0.002, y * 0.002, 456) * 0.7
			moisture += perlin_noise(x * 0.006, y * 0.006, 789) * 0.2
			moisture += perlin_noise(x * 0.02, y * 0.02, 790) * 0.1
			moisture_map["[x]"]["[y]"] = moisture

			// Elevation - MUCH larger scale for mountain ranges
			var/elevation = perlin_noise(x * 0.002, y * 0.002, 999) * 0.6
			elevation += perlin_noise(x * 0.005, y * 0.005, 777) * 0.3
			elevation += perlin_noise(x * 0.015, y * 0.015, 778) * 0.1
			elevation_map["[x]"]["[y]"] = max(0, min(1, (elevation + 1) / 2))

	for(var/x = 1; x <= MAP_SIZE; x++)
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/temp = temperature_map["[x]"]["[y]"]
			var/moisture = moisture_map["[x]"]["[y]"]
			var/elevation = elevation_map["[x]"]["[y]"]

			// Calculate scores for all biomes using their datum methods
			var/best_biome = null
			var/best_score = -1

			for(var/biome_id in GLOB.biome_registry)
				var/datum/biome/biome_datum = GLOB.biome_registry[biome_id]
				var/score = biome_datum.calculate_suitability_score(temp, moisture, elevation)

				if(score > best_score)
					best_score = score
					best_biome = biome_id

			// Assign the biome with the highest score
			biome_map["[x]"]["[y]"] = best_biome || BIOME_FOREST  // Fallback to forest

	// Count and log results
	var/list/biome_counts = list()
	for(var/x = 1; x <= MAP_SIZE; x++)
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/biome = biome_map["[x]"]["[y]"]
			biome_counts["[biome]"] = (biome_counts["[biome]"] || 0) + 1

	world.log << "Modular biome distribution: Forest=[biome_counts[BIOME_FOREST]] Swamp=[biome_counts[BIOME_SWAMP]] Mountain=[biome_counts[BIOME_MOUNTAIN]]"

	return list("biomes" = biome_map, "temperature" = temperature_map,
			"moisture" = moisture_map, "elevation" = elevation_map)
