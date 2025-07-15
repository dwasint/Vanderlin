/proc/generate_height_map(list/biome_map, list/elevation_map)
	world.log << "Generating enhanced height map for multi-level terrain..."
	var/list/height_map = list()

	for(var/x = 1; x <= MAP_SIZE; x++)
		height_map["[x]"] = list()
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/biome_id = biome_map["[x]"]["[y]"]
			var/elevation = elevation_map["[x]"]["[y]"]

			// Get the biome datum
			var/datum/biome/biome_datum = get_biome_datum(biome_id)
			if(!biome_datum)
				height_map["[x]"]["[y]"] = 0
				continue

			// Calculate base height using biome-specific logic
			var/height = biome_datum.calculate_height(elevation, x, y)

			// Apply biome-specific height noise
			height = biome_datum.apply_height_noise(height, elevation, x, y)

			height_map["[x]"]["[y]"] = height

	// Use better smoothing
	height_map = smooth_height_map_natural(height_map, biome_map)

	return height_map

/proc/smooth_height_map_natural(list/height_map, list/biome_map)
	var/list/smoothed = list()

	for(var/x = 1; x <= MAP_SIZE; x++)
		smoothed["[x]"] = list()
		for(var/y = 1; y <= MAP_SIZE; y++)
			var/current_height = height_map["[x]"]["[y]"]
			var/current_biome = biome_map["[x]"]["[y]"]

			// Count neighbor heights
			var/list/neighbor_heights = list()
			var/max_neighbor = 0
			var/min_neighbor = 3

			for(var/dx = -1; dx <= 1; dx++)
				for(var/dy = -1; dy <= 1; dy++)
					if(dx == 0 && dy == 0) continue
					var/nx = x + dx
					var/ny = y + dy
					if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
						var/n_height = height_map["[nx]"]["[ny]"]
						neighbor_heights += n_height
						max_neighbor = max(max_neighbor, n_height)
						min_neighbor = min(min_neighbor, n_height)

			// Don't smooth if we're a peak or valley
			if(current_height >= max_neighbor || current_height <= min_neighbor)
				smoothed["[x]"]["[y]"] = current_height
				continue

			// For transitions, prefer gradual changes
			var/height_diff = max_neighbor - min_neighbor
			if(height_diff > 1)
				// We're in a transition zone - pick intermediate height
				if(current_height > min_neighbor && current_height < max_neighbor)
					smoothed["[x]"]["[y]"] = current_height
				else
					smoothed["[x]"]["[y]"] = min_neighbor + 1
			else
				smoothed["[x]"]["[y]"] = current_height

	return smoothed
