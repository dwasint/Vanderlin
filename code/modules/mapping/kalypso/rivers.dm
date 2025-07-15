
// Edge-to-edge river generation
/proc/generate_river_system(list/env_data)
    world.log << "Generating edge-to-edge river system..."
    var/list/river_map = list()
    var/list/elevation_map = env_data["elevation"]
    var/list/moisture_map = env_data["moisture"]
    var/list/biome_map = env_data["biomes"]

    // Initialize river map
    for(var/x = 1; x <= MAP_SIZE; x++)
        river_map["[x]"] = list()
        for(var/y = 1; y <= MAP_SIZE; y++)
            river_map["[x]"]["[y]"] = 0

    // Generate 2-3 major rivers that cross the entire map
    var/river_count = rand(2, 3)

    for(var/i = 1; i <= river_count; i++)
        generate_edge_to_edge_river(river_map, elevation_map, moisture_map, biome_map)

    // Apply erosion around rivers
    apply_river_erosion(river_map, env_data)

    return river_map

/proc/generate_edge_to_edge_river(list/river_map, list/elevation_map, list/moisture_map, list/biome_map)
    // Pick random starting and ending edges
    var/start_edge = rand(1, 4)  // 1=north, 2=east, 3=south, 4=west
    var/end_edge = start_edge

    // Make sure we don't start and end on the same edge
    while(end_edge == start_edge)
        end_edge = rand(1, 4)

    var/start_x = 0
    var/start_y = 0
    var/end_x = 0
    var/end_y = 0

    // Set start position based on edge
    switch(start_edge)
        if(1) // North edge
            start_x = rand(1, MAP_SIZE)
            start_y = MAP_SIZE
        if(2) // East edge
            start_x = MAP_SIZE
            start_y = rand(1, MAP_SIZE)
        if(3) // South edge
            start_x = rand(1, MAP_SIZE)
            start_y = 1
        if(4) // West edge
            start_x = 1
            start_y = rand(1, MAP_SIZE)

    // Set end position based on edge
    switch(end_edge)
        if(1) // North edge
            end_x = rand(1, MAP_SIZE)
            end_y = MAP_SIZE
        if(2) // East edge
            end_x = MAP_SIZE
            end_y = rand(1, MAP_SIZE)
        if(3) // South edge
            end_x = rand(1, MAP_SIZE)
            end_y = 1
        if(4) // West edge
            end_x = 1
            end_y = rand(1, MAP_SIZE)

    // Generate river path from start to end
    var/list/river_path = trace_edge_to_edge_path(start_x, start_y, end_x, end_y, elevation_map, moisture_map)

    // Apply river to map with varying width
    for(var/i = 1; i <= river_path.len; i++)
        var/list/coords = river_path[i]
        var/x = coords[1]
        var/y = coords[2]

        // River width varies along its length - wider in middle
        var/progress = i / river_path.len
        var/width_factor = sin(progress * 180) // Sine wave for wider middle
        var/river_width = 1 + round(width_factor * 3)

        // Place river with proper clustering
        place_river_segment(river_map, x, y, river_width)

/proc/trace_edge_to_edge_path(start_x, start_y, end_x, end_y, list/elevation_map, list/moisture_map)
    var/list/path = list()
    var/x = start_x
    var/y = start_y
    var/target_x = end_x
    var/target_y = end_y

    // Add curving parameters
    var/curve_intensity = rand(10, 30) // How much the river curves (0-100)
    var/meander_frequency = rand(15, 22) // How often direction changes occur
    var/current_curve_bias_x = 0 // Current sideways bias
    var/current_curve_bias_y = 0
    var/steps_since_direction_change = 0
    var/preferred_side = pick(-1, 1) // Which side the river prefers to curve toward

    var/max_steps = MAP_SIZE * 3 // Increase max steps for longer, curvier paths
    var/steps = 0

    while(steps < max_steps)
        steps++
        path += list(list(x, y))

        // Check if we've reached the target
        if(abs(x - target_x) <= 1 && abs(y - target_y) <= 1)
            break

        // Update curve bias periodically to create meandering
        steps_since_direction_change++
        if(steps_since_direction_change >= meander_frequency)
            steps_since_direction_change = 0
            // Change curve direction with some randomness
            if(prob(70)) // 70% chance to change direction
                preferred_side *= -1

            // Calculate perpendicular direction to main flow for curving
            var/main_dx = target_x - x
            var/main_dy = target_y - y
            var/main_length = sqrt(main_dx*main_dx + main_dy*main_dy)

            if(main_length > 0)
                // Normalize main direction
                main_dx /= main_length
                main_dy /= main_length

                // Create perpendicular bias (90 degrees rotated)
                current_curve_bias_x = -main_dy * preferred_side * (curve_intensity / 100)
                current_curve_bias_y = main_dx * preferred_side * (curve_intensity / 100)

        // Find the best next step with curving bias
        var/best_x = x
        var/best_y = y
        var/best_score = 999999

        // Check all 8 directions
        for(var/dx = -1; dx <= 1; dx++)
            for(var/dy = -1; dy <= 1; dy++)
                if(dx == 0 && dy == 0)
                    continue

                var/nx = x + dx
                var/ny = y + dy

                // Keep within bounds
                if(nx < 1 || nx > MAP_SIZE || ny < 1 || ny > MAP_SIZE)
                    continue

                // Calculate base score (distance to target)
                var/distance_to_target = sqrt((nx - target_x) * (nx - target_x) + (ny - target_y) * (ny - target_y))

                // Terrain factors
                var/elevation_penalty = elevation_map["[nx]"]["[ny]"] * 0.3
                var/moisture_bonus = moisture_map["[nx]"]["[ny]"] * -0.1

                // Curving bias - favor moves in the preferred curve direction
                var/curve_bonus = 0
                if(current_curve_bias_x != 0 || current_curve_bias_y != 0)
                    // Dot product with curve direction
                    curve_bonus = -(dx * current_curve_bias_x + dy * current_curve_bias_y) * 2

                // Anti-straightness penalty - discourage continuing in exact same direction
                var/straightness_penalty = 0
                if(path.len >= 2)
                    var/list/prev_coords = path[path.len]
                    var/list/prev_prev_coords = path[path.len-1]
                    var/prev_dx = prev_coords[1] - prev_prev_coords[1]
                    var/prev_dy = prev_coords[2] - prev_prev_coords[2]

                    // If we're moving in the same direction as before, add penalty
                    if(dx == prev_dx && dy == prev_dy)
                        straightness_penalty = 1.5

                // Random noise for more natural variation
                var/noise = (rand() - 0.5) * 0.5

                var/total_score = distance_to_target + elevation_penalty + moisture_bonus + curve_bonus + straightness_penalty + noise

                if(total_score < best_score)
                    best_score = total_score
                    best_x = nx
                    best_y = ny

        // Move to best position
        x = best_x
        y = best_y

        // Reduce curve intensity as we get closer to target to ensure we reach it
        var/remaining_distance = sqrt((x - target_x) * (x - target_x) + (y - target_y) * (y - target_y))
        if(remaining_distance < MAP_SIZE * 0.2) // When we're in the final 20% of the journey
            curve_intensity *= 0.8 // Reduce curving to help reach target

    // Ensure we end at the target
    if(!(list(target_x, target_y) in path))
        path += list(list(target_x, target_y))

    world.log << "Generated curved edge-to-edge river path with [path.len] segments from ([start_x],[start_y]) to ([end_x],[end_y])"
    return path

/proc/place_river_segment(list/river_map, center_x, center_y, width)
    // Place river segment with proper circular/oval shape
    for(var/dx = -width; dx <= width; dx++)
        for(var/dy = -width; dy <= width; dy++)
            var/rx = center_x + dx
            var/ry = center_y + dy

            if(rx >= 1 && rx <= MAP_SIZE && ry >= 1 && ry <= MAP_SIZE)
                var/distance = sqrt(dx*dx + dy*dy)
                if(distance <= width)
                    river_map["[rx]"]["[ry]"] = 1

/proc/apply_river_erosion(list/river_map, list/env_data)
    var/list/erosion_map = list()

    // Initialize erosion map
    for(var/x = 1; x <= MAP_SIZE; x++)
        erosion_map["[x]"] = list()
        for(var/y = 1; y <= MAP_SIZE; y++)
            erosion_map["[x]"]["[y]"] = 0

    // Apply erosion around rivers with better falloff
    for(var/x = 1; x <= MAP_SIZE; x++)
        for(var/y = 1; y <= MAP_SIZE; y++)
            if(river_map["[x]"]["[y]"])
                // Erode surrounding area with smooth falloff
                for(var/dx = -4; dx <= 4; dx++)
                    for(var/dy = -4; dy <= 4; dy++)
                        var/ex = x + dx
                        var/ey = y + dy

                        if(ex >= 1 && ex <= MAP_SIZE && ey >= 1 && ey <= MAP_SIZE)
                            var/distance = sqrt(dx*dx + dy*dy)
                            if(distance <= 4)
                                var/erosion_strength = max(0, 1 - (distance / 4))
                                erosion_map["[ex]"]["[ey]"] = max(erosion_map["[ex]"]["[ey]"], erosion_strength)

    env_data["rivers"] = river_map
    env_data["erosion"] = erosion_map

/proc/generate_river_terrain(turf/T, list/env_data, x, y)
    var/list/river_map = env_data["rivers"]
    var/list/erosion_map = env_data["erosion"]
    var/list/elevation_map = env_data["elevation"]
    var/list/biome_map = env_data["biomes"]

    if(!river_map || !erosion_map)
        return

    var/is_river = river_map["[x]"]["[y]"]
    var/erosion_level = erosion_map["[x]"]["[y]"]
    var/elevation = elevation_map["[x]"]["[y]"]
    var/biome = biome_map["[x]"]["[y]"]

    // Only make changes where we want rivers or significant erosion
    if(is_river)
        // Determine river direction for flow animation
        var/river_dir = calculate_river_direction(x, y, river_map)

        // Different river types based on biome and elevation
        if(biome == BIOME_SWAMP || elevation < 0.3)
            T.ChangeTurf(/turf/open/water/river/dirt, flags = CHANGETURF_SKIP)
        else if(biome == BIOME_MOUNTAIN && elevation > 0.6)
            T.ChangeTurf(/turf/open/water/river, flags = CHANGETURF_SKIP)
        else
            T.ChangeTurf(/turf/open/water/river, flags = CHANGETURF_SKIP)

        // Set the river direction
        T.dir = river_dir

    else if(erosion_level > 0.6) // Only apply erosion effects for significant erosion
        // Heavily eroded areas become dirt/muddy
        if(erosion_level > 0.8)
            T.ChangeTurf(/turf/open/floor/dirt, flags = CHANGETURF_SKIP)
        else
            // Moderate erosion - riverbank effects
            if(biome == BIOME_SWAMP)
                T.ChangeTurf(/turf/open/floor/dirt, flags = CHANGETURF_SKIP)
            else if(biome == BIOME_MOUNTAIN)
                T.ChangeTurf(/turf/open/floor/dirt/road, flags = CHANGETURF_SKIP)

/proc/calculate_river_direction(x, y, list/river_map)
	// Check surrounding tiles to determine flow direction
	var/list/flow_directions = list()

	for(var/dx = -1; dx <= 1; dx++)
		for(var/dy = -1; dy <= 1; dy++)
			if(dx == 0 && dy == 0)
				continue

			var/nx = x + dx
			var/ny = y + dy

			if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
				if(river_map["[nx]"]["[ny]"])
					// Convert dx,dy to BYOND direction
					var/direction = get_dir_from_offset(dx, dy)
					flow_directions += direction

	// Return the most common direction, or default to NORTH
	if(flow_directions.len > 0)
		return pick(flow_directions)

	return NORTH

/proc/get_dir_from_offset(dx, dy)
	if(dx == 0 && dy == 1)
		return NORTH
	else if(dx == 1 && dy == 1)
		return NORTHEAST
	else if(dx == 1 && dy == 0)
		return EAST
	else if(dx == 1 && dy == -1)
		return SOUTHEAST
	else if(dx == 0 && dy == -1)
		return SOUTH
	else if(dx == -1 && dy == -1)
		return SOUTHWEST
	else if(dx == -1 && dy == 0)
		return WEST
	else if(dx == -1 && dy == 1)
		return NORTHWEST

	return NORTH
