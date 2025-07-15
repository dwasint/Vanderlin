// Enhanced cave generation with branching tunnels, lava lakes, and rivers
#define CAVE_EMPTY 0
#define CAVE_WALL 1
#define CAVE_TUNNEL 2
#define CAVE_CHAMBER 3
#define CAVE_LAVA_LAKE 4
#define CAVE_LAVA_RIVER 5
#define CAVE_LAVA_STREAM 6
#define CAVE_WATER 7
#define CAVE_MUD 8
#define CAVE_CRYSTAL 9

/proc/generate_cave_system(list/env_data)
    world.log << "Generating advanced cave systems with lava features..."
    var/list/cave_map = list()
    var/list/biome_map = env_data["biomes"]
    var/list/elevation_map = env_data["elevation"]

    // Initialize cave map
    for(var/x = 1; x <= MAP_SIZE; x++)
        cave_map["[x]"] = list()
        for(var/y = 1; y <= MAP_SIZE; y++)
            cave_map["[x]"]["[y]"] = CAVE_WALL

    // Generate base cave structure with multiple noise layers
    cave_map = generate_base_caves(cave_map, biome_map, elevation_map)

    // Create branching tunnel networks BEFORE cellular automata
    cave_map = generate_tunnel_networks(cave_map, biome_map)

    // Add large chambers at tunnel intersections
    cave_map = generate_cave_chambers(cave_map)

    // Apply cellular automata for natural cave shapes (reduced iterations)
    cave_map = refine_caves_cellular_automata(cave_map, 2)

    // Generate lava features AFTER caves are established
    cave_map = generate_lava_features(cave_map, biome_map, elevation_map)

    // Ensure connectivity between major cave systems
    //cave_map = ensure_cave_connectivity(cave_map)

    return cave_map

/proc/generate_base_caves(list/cave_map, list/biome_map, list/elevation_map)
    // Generate sparse seed caves that tunnels will connect
    var/seed_cave_count = rand(15, 25)

    for(var/i = 1; i <= seed_cave_count; i++)
        var/seed_x = rand(10, MAP_SIZE-10)
        var/seed_y = rand(10, MAP_SIZE-10)
        var/seed_size = rand(3, 8)

        // Create small seed caves
        for(var/dx = -seed_size; dx <= seed_size; dx++)
            for(var/dy = -seed_size; dy <= seed_size; dy++)
                var/dist = sqrt(dx*dx + dy*dy)
                if(dist <= seed_size)
                    var/nx = seed_x + dx
                    var/ny = seed_y + dy
                    if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                        // Add some irregularity
                        var/noise = simple_noise(nx * 0.2, ny * 0.2, 1000 + i)
                        if(noise > -0.3)
                            cave_map["[nx]"]["[ny]"] = CAVE_EMPTY

    // Add some scattered individual caves with very sparse noise
    for(var/x = 1; x <= MAP_SIZE; x++)
        for(var/y = 1; y <= MAP_SIZE; y++)
            var/cave_noise = simple_noise(x * 0.01, y * 0.01, 2000)
            var/detail_noise = simple_noise(x * 0.03, y * 0.03, 3000) * 0.2

            var/combined_noise = cave_noise + detail_noise

            // Much higher threshold for very sparse caves
            var/cave_threshold = 0.65
            if(biome_map["[x]"]["[y]"] == BIOME_MOUNTAIN)
                cave_threshold = 0.55
                combined_noise += simple_noise(x * 0.005, y * 0.005, 4000) * 0.3

            // Elevation affects cave probability - deeper = more caves
            var/elevation_factor = 1.2 - elevation_map["[x]"]["[y]"] * 0.5
            combined_noise *= elevation_factor

            if(combined_noise > cave_threshold)
                cave_map["[x]"]["[y]"] = CAVE_EMPTY

    return cave_map

/proc/generate_tunnel_networks(list/cave_map, list/biome_map)
    var/tunnel_count = rand(8, 12) // Fewer but more defined tunnels

    for(var/i = 1; i <= tunnel_count; i++)
        // Find existing cave areas to connect
        var/start_x, start_y, target_x, target_y
        var/attempts = 0

        // Find a cave area to start from
        do
            start_x = rand(15, MAP_SIZE-15)
            start_y = rand(15, MAP_SIZE-15)
            attempts++
        while(cave_map["[start_x]"]["[start_y]"] == CAVE_WALL && attempts < 100)

        if(attempts >= 100)
            // Fallback: create starting point
            start_x = rand(15, MAP_SIZE-15)
            start_y = rand(15, MAP_SIZE-15)
            cave_map["[start_x]"]["[start_y]"] = CAVE_EMPTY

        // Find another cave area to connect to
        attempts = 0
        do
            target_x = rand(15, MAP_SIZE-15)
            target_y = rand(15, MAP_SIZE-15)
            attempts++
        while(cave_map["[target_x]"]["[target_y]"] == CAVE_WALL && attempts < 100)

        if(attempts >= 100)
            // Create a target in a random direction
            var/angle = rand(0, 360)
            var/distance = rand(50, 100)
            target_x = start_x + round(cos(angle * 0.0174533) * distance)
            target_y = start_y + round(sin(angle * 0.0174533) * distance)
            target_x = max(1, min(MAP_SIZE, target_x))
            target_y = max(1, min(MAP_SIZE, target_y))

        // Generate tunnel connecting these points
        generate_connecting_tunnel(cave_map, start_x, start_y, target_x, target_y)

    return cave_map

/proc/generate_connecting_tunnel(list/cave_map, start_x, start_y, target_x, target_y)
    var/x = start_x
    var/y = start_y
    var/tunnel_width = rand(1, 3) // Narrower tunnels
    var/branch_countdown = rand(25, 40) // Less frequent branching
    var/steps_taken = 0
    var/max_steps = 200

    while((abs(x - target_x) > 3 || abs(y - target_y) > 3) && steps_taken < max_steps)
        steps_taken++

        // Carve tunnel segment
        for(var/dx = -tunnel_width; dx <= tunnel_width; dx++)
            for(var/dy = -tunnel_width; dy <= tunnel_width; dy++)
                var/dist = sqrt(dx*dx + dy*dy)
                if(dist <= tunnel_width)
                    var/nx = x + dx
                    var/ny = y + dy
                    if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                        cave_map["[nx]"]["[ny]"] = CAVE_TUNNEL

        // Calculate direction to target
        var/dx = target_x - x
        var/dy = target_y - y
        var/distance = sqrt(dx*dx + dy*dy)

        if(distance > 0)
            dx = dx / distance
            dy = dy / distance

        // Add some randomness but bias toward target
        dx += rand(-0.2, 0.2)
        dy += rand(-0.2, 0.2)

        // Normalize
        distance = sqrt(dx*dx + dy*dy)
        if(distance > 0)
            dx = dx / distance
            dy = dy / distance

        // Move toward target
        x += round(dx * 1.5)
        y += round(dy * 1.5)

        // Keep within bounds
        x = max(1, min(MAP_SIZE, x))
        y = max(1, min(MAP_SIZE, y))

        // Branch generation with countdown
        branch_countdown--
        if(branch_countdown <= 0 && steps_taken > 15 && steps_taken < max_steps - 20)
            branch_countdown = rand(30, 50) // Reset countdown

            // Create shorter branches
            var/branch_length = rand(15, 30)
            var/branch_angle = rand(0, 360)
            var/branch_target_x = x + round(cos(branch_angle * 0.0174533) * branch_length)
            var/branch_target_y = y + round(sin(branch_angle * 0.0174533) * branch_length)
            branch_target_x = max(1, min(MAP_SIZE, branch_target_x))
            branch_target_y = max(1, min(MAP_SIZE, branch_target_y))

            generate_simple_branch(cave_map, x, y, branch_target_x, branch_target_y, max(1, tunnel_width - 1))

        // Occasionally widen tunnel
        if(prob(5))
            tunnel_width = min(tunnel_width + 1, 4)
        else if(prob(5))
            tunnel_width = max(tunnel_width - 1, 1)

/proc/generate_simple_branch(list/cave_map, start_x, start_y, target_x, target_y, width)
    var/x = start_x
    var/y = start_y
    var/steps = 0
    var/max_steps = 50 // Shorter branches

    while((abs(x - target_x) > 2 || abs(y - target_y) > 2) && steps < max_steps)
        steps++

        // Carve branch
        for(var/dx = -width; dx <= width; dx++)
            for(var/dy = -width; dy <= width; dy++)
                var/dist = sqrt(dx*dx + dy*dy)
                if(dist <= width)
                    var/nx = x + dx
                    var/ny = y + dy
                    if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                        cave_map["[nx]"]["[ny]"] = CAVE_TUNNEL

        // Move toward target
        if(x < target_x) x++
        else if(x > target_x) x--
        if(y < target_y) y++
        else if(y > target_y) y--

        // Add small random deviation
        x += rand(-1, 1)
        y += rand(-1, 1)

        // Keep within bounds
        x = max(1, min(MAP_SIZE, x))
        y = max(1, min(MAP_SIZE, y))

/proc/generate_cave_chambers(list/cave_map)
    // Find tunnel intersections and widen them into chambers
    for(var/x = 8; x <= MAP_SIZE-8; x += 5) // Less frequent checking
        for(var/y = 8; y <= MAP_SIZE-8; y += 5)
            if(cave_map["[x]"]["[y]"] == CAVE_TUNNEL)
                var/tunnel_connections = count_tunnel_connections(cave_map, x, y)

                if(tunnel_connections >= 2) // Junction point
                    var/chamber_size = rand(4, 8) // Smaller chambers
                    create_chamber(cave_map, x, y, chamber_size)

    return cave_map

/proc/count_tunnel_connections(list/cave_map, x, y)
    var/connections = 0
    var/list/directions = list(
        list(0, 3), list(0, -3), list(3, 0), list(-3, 0),
        list(2, 2), list(2, -2), list(-2, 2), list(-2, -2)
    )

    for(var/list/dir in directions)
        var/nx = x + dir[1]
        var/ny = y + dir[2]
        if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
            if(cave_map["[nx]"]["[ny]"] == CAVE_TUNNEL)
                connections++

    return connections

/proc/create_chamber(list/cave_map, center_x, center_y, size)
    for(var/dx = -size; dx <= size; dx++)
        for(var/dy = -size; dy <= size; dy++)
            var/dist = sqrt(dx*dx + dy*dy)
            if(dist <= size)
                var/nx = center_x + dx
                var/ny = center_y + dy
                if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                    cave_map["[nx]"]["[ny]"] = CAVE_CHAMBER

/proc/generate_lava_features(list/cave_map, list/biome_map, list/elevation_map)
    // Generate main lava river system FIRST
    cave_map = generate_lava_river_system(cave_map, biome_map, elevation_map)

    // Generate smaller lava streams FROM rivers
    cave_map = generate_lava_streams(cave_map)

    // Generate lava lakes last
    cave_map = generate_lava_lakes(cave_map, biome_map, elevation_map)

    return cave_map

/proc/generate_lava_river_system(list/cave_map, list/biome_map, list/elevation_map)
    var/main_rivers = rand(2, 4) // More rivers

    for(var/i = 1; i <= main_rivers; i++)
        // Find a cave area to start the river
        var/start_x, start_y, target_x, target_y
        var/attempts = 0

        do
            start_x = rand(20, MAP_SIZE-20)
            start_y = rand(20, MAP_SIZE-20)
            attempts++
        while(cave_map["[start_x]"]["[start_y]"] == CAVE_WALL && attempts < 50)

        if(attempts >= 50) continue // Skip if no cave found

        // Target another cave area
        attempts = 0
        do
            target_x = rand(20, MAP_SIZE-20)
            target_y = rand(20, MAP_SIZE-20)
            attempts++
        while(cave_map["[target_x]"]["[target_y]"] == CAVE_WALL && attempts < 50)

        if(attempts >= 50) continue // Skip if no target found

        generate_lava_river(cave_map, start_x, start_y, target_x, target_y, rand(3, 6))

    return cave_map

/proc/generate_lava_river(list/cave_map, start_x, start_y, target_x, target_y, width)
    var/x = start_x
    var/y = start_y
    var/steps_taken = 0
    var/max_steps = 500 // Prevent infinite loops

    while((abs(x - target_x) > 2 || abs(y - target_y) > 2) && steps_taken < max_steps)
        steps_taken++

        // Calculate direction to target
        var/dx = target_x - x
        var/dy = target_y - y
        var/distance = sqrt(dx*dx + dy*dy)

        if(distance > 0)
            dx = dx / distance
            dy = dy / distance

        // Add some randomness
        dx += rand(-0.3, 0.3)
        dy += rand(-0.3, 0.3)

        // Normalize again
        distance = sqrt(dx*dx + dy*dy)
        if(distance > 0)
            dx = dx / distance
            dy = dy / distance

        // Move towards target
        x += round(dx * 2)
        y += round(dy * 2)

        // Keep within bounds
        x = max(1, min(MAP_SIZE, x))
        y = max(1, min(MAP_SIZE, y))

        // Carve lava river (only in existing caves)
        for(var/rdx = -width; rdx <= width; rdx++)
            for(var/rdy = -width; rdy <= width; rdy++)
                var/dist = sqrt(rdx*rdx + rdy*rdy)
                if(dist <= width)
                    var/nx = x + rdx
                    var/ny = y + rdy
                    if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                        if(cave_map["[nx]"]["[ny]"] != CAVE_WALL)
                            cave_map["[nx]"]["[ny]"] = CAVE_LAVA_RIVER

        // Create branches less frequently but more reliably
        if(steps_taken % 25 == 0 && prob(30))
            var/branch_length = rand(20, 50)
            var/branch_target_x = x + rand(-40, 40)
            var/branch_target_y = y + rand(-40, 40)
            branch_target_x = max(1, min(MAP_SIZE, branch_target_x))
            branch_target_y = max(1, min(MAP_SIZE, branch_target_y))

            generate_lava_river(cave_map, x, y, branch_target_x, branch_target_y, max(1, width - 1))

/proc/generate_lava_lakes(list/cave_map, list/biome_map, list/elevation_map)
    var/lake_count = rand(3, 6)

    for(var/i = 1; i <= lake_count; i++)
        // Find existing lava rivers to place lakes
        var/lake_x, lake_y
        var/attempts = 0
        var/found_river = 0

        while(!found_river && attempts < 100)
            lake_x = rand(15, MAP_SIZE-15)
            lake_y = rand(15, MAP_SIZE-15)
            attempts++

            if(cave_map["[lake_x]"]["[lake_y]"] == CAVE_LAVA_RIVER)
                found_river = 1
                break

        if(!found_river)
            // Fallback: place in any cave
            attempts = 0
            do
                lake_x = rand(15, MAP_SIZE-15)
                lake_y = rand(15, MAP_SIZE-15)
                attempts++
            while(cave_map["[lake_x]"]["[lake_y]"] == CAVE_WALL && attempts < 50)

            if(attempts >= 50) continue

        var/lake_size = rand(6, 12)
        create_lava_lake(cave_map, lake_x, lake_y, lake_size)

    return cave_map

/proc/create_lava_lake(list/cave_map, center_x, center_y, size)
    for(var/dx = -size; dx <= size; dx++)
        for(var/dy = -size; dy <= size; dy++)
            var/dist = sqrt(dx*dx + dy*dy)
            // Create irregular lake shape
            var/noise_factor = simple_noise((center_x + dx) * 0.1, (center_y + dy) * 0.1, 5000) * 0.4
            if(dist <= size + noise_factor)
                var/nx = center_x + dx
                var/ny = center_y + dy
                if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                    if(cave_map["[nx]"]["[ny]"] != CAVE_WALL)
                        cave_map["[nx]"]["[ny]"] = CAVE_LAVA_LAKE

/proc/generate_lava_streams(list/cave_map)
    // Generate small lava streams FROM existing rivers and lakes
    var/stream_count = 0
    for(var/x = 1; x <= MAP_SIZE; x++)
        for(var/y = 1; y <= MAP_SIZE; y++)
            if(cave_map["[x]"]["[y]"] == CAVE_LAVA_RIVER || cave_map["[x]"]["[y]"] == CAVE_LAVA_LAKE)
                // Chance to spawn small streams
                if(prob(8) && stream_count < 20) // Limit total streams
                    stream_count++
                    var/stream_dir = rand(0, 360)
                    var/stream_length = rand(15, 35)
                    generate_lava_stream(cave_map, x, y, stream_dir, stream_length)

    return cave_map

/proc/generate_lava_stream(list/cave_map, start_x, start_y, direction, length)
    var/x = start_x
    var/y = start_y
    var/current_dir = direction

    for(var/step = 1; step <= length; step++)
        // Carve narrow stream (only in existing caves)
        for(var/dx = -1; dx <= 1; dx++)
            for(var/dy = -1; dy <= 1; dy++)
                var/nx = x + dx
                var/ny = y + dy
                if(nx >= 1 && nx <= MAP_SIZE && ny >= 1 && ny <= MAP_SIZE)
                    if(cave_map["[nx]"]["[ny]"] != CAVE_WALL)
                        cave_map["[nx]"]["[ny]"] = CAVE_LAVA_STREAM

        // Less random direction changes for straighter streams
        current_dir += rand(-20, 20)
        if(current_dir < 0) current_dir += 360
        if(current_dir >= 360) current_dir -= 360

        // Move forward
        x += round(cos(current_dir * 0.0174533) * 1.5)
        y += round(sin(current_dir * 0.0174533) * 1.5)

        // Keep within bounds
        x = max(1, min(MAP_SIZE, x))
        y = max(1, min(MAP_SIZE, y))

        // Stop if we hit a wall
        if(cave_map["[x]"]["[y]"] == CAVE_WALL)
            break

/proc/refine_caves_cellular_automata(list/cave_map, iterations = 2)
    for(var/iter = 1; iter <= iterations; iter++)
        var/list/new_cave_map = list()

        for(var/x = 1; x <= MAP_SIZE; x++)
            new_cave_map["[x]"] = list()
            for(var/y = 1; y <= MAP_SIZE; y++)
                var/current_type = cave_map["[x]"]["[y]"]

                // Don't modify ANY carved features - preserve the tunnel network
                if(current_type == CAVE_LAVA_LAKE || current_type == CAVE_LAVA_RIVER || current_type == CAVE_LAVA_STREAM || current_type == CAVE_TUNNEL || current_type == CAVE_CHAMBER)
                    new_cave_map["[x]"]["[y]"] = current_type
                    continue

                var/wall_count = 0
                var/cave_count = 0

                // Count walls and caves in 3x3 neighborhood
                for(var/dx = -1; dx <= 1; dx++)
                    for(var/dy = -1; dy <= 1; dy++)
                        var/nx = x + dx
                        var/ny = y + dy
                        if(nx < 1 || nx > MAP_SIZE || ny < 1 || ny > MAP_SIZE)
                            wall_count++
                        else
                            var/neighbor_type = cave_map["[nx]"]["[ny]"]
                            if(neighbor_type == CAVE_WALL)
                                wall_count++
                            else
                                cave_count++

                // Very conservative rules - only smooth existing caves
                if(wall_count >= 7)
                    new_cave_map["[x]"]["[y]"] = CAVE_WALL
                else if(cave_count >= 6)
                    new_cave_map["[x]"]["[y]"] = CAVE_EMPTY
                else
                    new_cave_map["[x]"]["[y]"] = current_type

        cave_map = new_cave_map

    return cave_map

/proc/ensure_cave_connectivity(list/cave_map)
    var/list/cave_regions = find_cave_regions(cave_map)

    if(cave_regions.len <= 1)
        return cave_map

    // Connect largest regions
    var/list/largest_region = cave_regions[1]
    for(var/i = 2; i <= cave_regions.len; i++)
        var/list/cave_sector = cave_regions[i]
        if(cave_sector.len > largest_region.len)
            largest_region = cave_regions[i]

    // Connect other regions to largest
    for(var/region in cave_regions)
        if(region == largest_region)
            continue

        var/list/connection_path = find_connection_path(largest_region, region)
        for(var/list/coords in connection_path)
            cave_map["[coords[1]]"]["[coords[2]]"] = CAVE_TUNNEL

    return cave_map

/proc/find_cave_regions(list/cave_map)
    var/list/regions = list()
    var/list/visited = list()

    // Initialize visited array
    for(var/x = 1; x <= MAP_SIZE; x++)
        visited["[x]"] = list()
        for(var/y = 1; y <= MAP_SIZE; y++)
            visited["[x]"]["[y]"] = 0

    // Find connected components using flood fill
    for(var/x = 1; x <= MAP_SIZE; x++)
        for(var/y = 1; y <= MAP_SIZE; y++)
            var/cell_type = cave_map["[x]"]["[y]"]
            if(cell_type != CAVE_WALL && !visited["[x]"]["[y]"])
                var/list/region = flood_fill_region(cave_map, visited, x, y)
                if(region.len > 15) // Minimum region size
                    regions += list(region)

    return regions

/proc/flood_fill_region(list/cave_map, list/visited, start_x, start_y)
    var/list/region = list()
    var/list/stack = list(list(start_x, start_y))

    while(stack.len > 0)
        var/list/current = stack[stack.len]
        stack.len--

        var/x = current[1]
        var/y = current[2]

        if(x < 1 || x > MAP_SIZE || y < 1 || y > MAP_SIZE)
            continue
        if(visited["[x]"]["[y]"] || cave_map["[x]"]["[y]"] == CAVE_WALL)
            continue

        visited["[x]"]["[y]"] = 1
        region += list(list(x, y))

        // Add neighbors to stack
        stack += list(list(x+1, y), list(x-1, y), list(x, y+1), list(x, y-1))

    return region

/proc/find_connection_path(list/region1, list/region2)
    // Find closest points between regions
    var/list/closest1 = region1[1]
    var/list/closest2 = region2[1]
    var/min_dist = 999999

    for(var/list/point1 in region1)
        for(var/list/point2 in region2)
            var/dist = sqrt((point1[1] - point2[1])**2 + (point1[2] - point2[2])**2)
            if(dist < min_dist)
                min_dist = dist
                closest1 = point1
                closest2 = point2

    // Create path between closest points
    var/list/path = list()
    var/x = closest1[1]
    var/y = closest1[2]
    var/target_x = closest2[1]
    var/target_y = closest2[2]

    while(x != target_x || y != target_y)
        path += list(list(x, y))
        if(x < target_x) x++
        else if(x > target_x) x--
        if(y < target_y) y++
        else if(y > target_y) y--

    return path

// Helper functions remain the same
/proc/get_cave_type(list/cave_map, x, y)
    if(x < 1 || x > MAP_SIZE || y < 1 || y > MAP_SIZE)
        return CAVE_WALL
    return cave_map["[x]"]["[y]"]

/proc/is_lava_tile(list/cave_map, x, y)
    var/cave_type = get_cave_type(cave_map, x, y)
    return (cave_type == CAVE_LAVA_LAKE || cave_type == CAVE_LAVA_RIVER || cave_type == CAVE_LAVA_STREAM)

/proc/get_lava_intensity(list/cave_map, x, y)
    var/cave_type = get_cave_type(cave_map, x, y)
    switch(cave_type)
        if(CAVE_LAVA_LAKE)
            return 3
        if(CAVE_LAVA_RIVER)
            return 2
        if(CAVE_LAVA_STREAM)
            return 1
        else
            return 0

/proc/generate_underground_terrain(list/biome_map, list/elevation_map, list/cave_map, list/ore_map)
    world.log << "Generating underground terrain with caves and ore..."
    for(var/x = 1; x <= MAP_SIZE; x++)
        for(var/y = 1; y <= MAP_SIZE; y++)
            var/turf/T = locate(x, y, Z_UNDERGROUND)
            if(!T) continue
            var/biome = biome_map["[x]"]["[y]"]
            var/elevation = elevation_map["[x]"]["[y]"]
            var/cave_type = cave_map["[x]"]["[y]"]
            var/ore_type = ore_map["[x]"]["[y]"]

            // Check if this is a cave area (any non-wall type)
            if(cave_type != CAVE_WALL)
                // Handle different cave types
                switch(cave_type)
                    if(CAVE_LAVA_LAKE)
                        T.ChangeTurf(/turf/open/lava, flags = CHANGETURF_SKIP)
                    if(CAVE_LAVA_RIVER)
                        T.ChangeTurf(/turf/open/lava, flags = CHANGETURF_SKIP)
                    if(CAVE_LAVA_STREAM)
                        T.ChangeTurf(/turf/open/lava, flags = CHANGETURF_SKIP)
                    else // CAVE_EMPTY, CAVE_TUNNEL, CAVE_CHAMBER
                        // Regular cave floor based on biome
                        switch(biome)
                            if(BIOME_MOUNTAIN)
                                T.ChangeTurf(/turf/open/floor/naturalstone, flags = CHANGETURF_SKIP)
                            if(BIOME_SWAMP)
                                T.ChangeTurf(/turf/open/floor/naturalstone, flags = CHANGETURF_SKIP)
                            else
                                T.ChangeTurf(/turf/open/floor/naturalstone, flags = CHANGETURF_SKIP)

                // Add cave features (but not on lava)
                if(!is_lava_tile(cave_map, x, y))
                    add_cave_features(T, biome, elevation, x, y)
                    // Place ore if present
                    if(ore_type)
                        place_ore_deposit(T, ore_type)
            else
                // Solid rock (CAVE_WALL)
                switch(biome)
                    if(BIOME_MOUNTAIN)
                        T.ChangeTurf(/turf/closed/mineral, flags = CHANGETURF_SKIP)
                    if(BIOME_SWAMP)
                        T.ChangeTurf(/turf/closed/mineral, flags = CHANGETURF_SKIP)
                    else
                        T.ChangeTurf(/turf/closed/mineral, flags = CHANGETURF_SKIP)
                // Ore in solid rock (rare)
                if(ore_type && prob(20))
                    place_ore_deposit(T, ore_type)
