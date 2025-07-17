// Feature spawning system
/proc/spawn_world_features(list/env_data)
	world.log << "Spawning world features..."

	GLOB.spawned_features = list()
	GLOB.flora_blocked_tiles = list()

	// Get all feature templates
	var/list/feature_templates = list()
	for(var/template_path in subtypesof(/datum/map_template/world_feature))
		var/datum/map_template/world_feature/template = new template_path()
		feature_templates += template

	for(var/z = Z_GROUND; z <= Z_HIGH_AIR; z++)
		spawn_features_on_z_level(env_data, feature_templates, z)

	world.log << "Spawned [length(GLOB.spawned_features)] world features"

/proc/spawn_features_on_z_level(list/env_data, list/feature_templates, z_level)
	var/list/biome_map = env_data["biomes"]

	var/list/biome_locations = index_biome_locations(biome_map, feature_templates)

	var/list/biome_feature_counts = list()

	for(var/datum/map_template/world_feature/template in feature_templates)
		if(!template.ignores_z_restrictions)
			if(template.spawn_on_z_level != z_level)
				continue

		var/list/valid_biomes = get_valid_biomes_for_template(template)

		var/attempts = 0
		var/max_attempts = 50

		while(attempts < max_attempts)
			attempts++

			var/target_biome = pick(valid_biomes)

			var/current_count = biome_feature_counts["[target_biome]_[template.id]"] || 0
			if(current_count >= template.max_per_biome)
				valid_biomes -= target_biome
				if(!valid_biomes.len)
					break
				continue

			// Check rarity
			if(!prob(template.rarity * 100)) //TODO: for ease change this to just a 0 to 100 range
				continue

			var/list/biome_coords = biome_locations[target_biome]
			if(!biome_coords || !biome_coords.len)
				continue

			var/list/coord = pick(biome_coords)
			var/x = coord[1]
			var/y = coord[2]

			x = max(1 + template.width/2, min(MAP_SIZE - template.width/2, x))
			y = max(1 + template.height/2, min(MAP_SIZE - template.height/2, y))

			if(can_spawn_feature(template, x, y, z_level, env_data))
				if(spawn_feature_at_location(template, x, y, z_level))
					biome_feature_counts["[target_biome]_[template.id]"] = current_count + 1
					world.log << "Spawned [template.name] at ([x],[y],[z_level]) in biome [target_biome]"
					break

/proc/index_biome_locations(list/biome_map, list/feature_templates)
	var/list/biome_locations = list()

	var/list/relevant_biomes = list()
	for(var/datum/map_template/world_feature/template in feature_templates)
		var/list/valid_biomes = get_valid_biomes_for_template(template)
		for(var/biome in valid_biomes)
			relevant_biomes[biome] = TRUE

	for(var/biome in relevant_biomes)
		biome_locations[biome] = list()

	for(var/x in 1 to MAP_SIZE)
		for(var/y in 1 to MAP_SIZE)
			var/biome = biome_map["[x]"]["[y]"]
			if(biome in relevant_biomes)
				biome_locations[biome] += list(list(x, y))

	return biome_locations

/proc/get_valid_biomes_for_template(datum/map_template/world_feature/template)
	var/list/valid_biomes = list()

	valid_biomes = template.allowed_biomes.Copy()

	if(template.biome_blacklist && length(template.biome_blacklist))
		valid_biomes -= template.biome_blacklist

	return valid_biomes

/proc/can_spawn_feature(datum/map_template/world_feature/template, x, y, z_level, list/env_data)
	var/list/temperature_map = env_data["temperature"]
	var/list/moisture_map = env_data["moisture"]
	var/list/elevation_map = env_data["elevation"]
	var/list/river_map = env_data["rivers"]

	// Check all tiles the feature would occupy
	for(var/dx = -(template.width/2); dx <= (template.width/2); dx++)
		for(var/dy = -(template.height/2); dy <= (template.height/2); dy++)
			var/check_x = x + dx
			var/check_y = y + dy

			// Bounds check
			if(check_x < 1 || check_x > MAP_SIZE || check_y < 1 || check_y > MAP_SIZE)
				return FALSE

			// Get tile data
			var/temperature = temperature_map["[check_x]"]["[check_y]"]
			var/moisture = moisture_map["[check_x]"]["[check_y]"]
			var/elevation = elevation_map["[check_x]"]["[check_y]"]

			// Check environmental requirements
			if(elevation < template.min_elevation || elevation > template.max_elevation)
				return FALSE

			if(moisture < template.min_moisture || moisture > template.max_moisture)
				return FALSE

			if(temperature < template.min_temperature || temperature > template.max_temperature)
				return FALSE

			if(template.avoid_rivers && river_map && river_map["[check_x]"]["[check_y]"])
				return FALSE

			var/turf/T = locate(check_x, check_y, z_level)
			if(!T || istransparentturf(T))
				return FALSE

			if(template.avoid_walls && T.density)
				return FALSE

			if(template.avoid_water && istype(T, /turf/open/water))
				return FALSE

	if(template.min_distance_from_features > 0)
		for(var/feature_data in GLOB.spawned_features)
			var/list/feature_info = feature_data
			var/feature_x = feature_info["x"]
			var/feature_y = feature_info["y"]
			var/feature_z = feature_info["z"]

			if(feature_z == z_level)
				var/distance = sqrt((x - feature_x) ** 2 + (y - feature_y) ** 2)
				if(distance < template.min_distance_from_features)
					return FALSE

/proc/spawn_feature_at_location(datum/map_template/world_feature/template, x, y, z_level)
	if(!template.mappath)
		world.log << "ERROR: No mappath for template [template.name]"
		return FALSE

	var/spawn_x = x - (template.width / 2)
	var/spawn_y = y - (template.height / 2)

	var/success = template.load(locate(spawn_x, spawn_y, z_level))

	if(success)
		var/list/feature_info = list(
			"template" = template,
			"x" = x,
			"y" = y,
			"z" = z_level,
			"spawn_x" = spawn_x,
			"spawn_y" = spawn_y
		)
		GLOB.spawned_features += list(feature_info)
		if(template.blocks_flora)
			mark_flora_blocked_area(x, y, z_level, template.flora_block_radius)
		template.blocked_tiles = get_blocked_tiles_for_feature(spawn_x, spawn_y, z_level, template.width, template.height)

		return TRUE

	return FALSE

/proc/mark_flora_blocked_area(center_x, center_y, z_level, radius)
	for(var/x = center_x - radius; x <= center_x + radius; x++)
		for(var/y = center_y - radius; y <= center_y + radius; y++)
			if(x >= 1 && x <= MAP_SIZE && y >= 1 && y <= MAP_SIZE)
				var/tile_key = "[x],[y],[z_level]"
				if(!(tile_key in GLOB.flora_blocked_tiles))
					GLOB.flora_blocked_tiles += tile_key

/proc/get_blocked_tiles_for_feature(spawn_x, spawn_y, z_level, width, height)
	var/list/blocked = list()

	for(var/x = spawn_x; x < spawn_x + width; x++)
		for(var/y = spawn_y; y < spawn_y + height; y++)
			if(x >= 1 && x <= MAP_SIZE && y >= 1 && y <= MAP_SIZE)
				blocked += "[x],[y],[z_level]"

	return blocked

/proc/is_flora_blocked(x, y, z_level)
	var/tile_key = "[x],[y],[z_level]"
	return (tile_key in GLOB.flora_blocked_tiles)
