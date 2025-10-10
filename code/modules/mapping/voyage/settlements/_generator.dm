/datum/settlement_generator
	var/datum/island_biome/biome
	var/list/building_templates = list(
		/datum/settlement_building_template/house_1,
	)
	var/list/path_turfs = list(
		/turf/open/floor/dirt,
		/turf/open/floor/cobblerock,
	)
	var/list/bridge_turfs = list(
		/turf/open/floor/ruinedwood
	)
	var/list/mob_spawn_type

	var/settlement_radius = 40
	var/min_building_distance = 8
	var/max_building_attempts = 150
	var/path_width = 1

	// Road generation
	var/road_smoothness = 0.7
	var/max_path_deviation = 3
	var/road_avoidance_padding = 2

/datum/settlement_generator/New(datum/island_biome/selected_biome)
	..()
	biome = selected_biome
	mob_spawn_type = selected_biome.settlement_mobs

/datum/settlement_generator/proc/generate_settlements(datum/island_generator/island_gen, turf/bottom_left_corner, list/mainland_tiles)
	if(!building_templates.len || !mainland_tiles.len)
		return

	var/list/coord_to_tile = list()
	for(var/list/tile_data in mainland_tiles)
		coord_to_tile["[tile_data["x"]],[tile_data["y"]]"] = tile_data

	var/settlement_min_distance = min_building_distance
	var/settlement_max_distance = min_building_distance * 1.5

	var/list/settlement_samples = island_gen.noise.poisson_disk_sampling(
		0, island_gen.size_x - 1,
		0, island_gen.size_y - 1,
		settlement_min_distance,
		settlement_max_distance
	)

	var/list/placed_settlements = list()

	for(var/list/sample in shuffle(settlement_samples))
		var/sx = round(sample[1])
		var/sy = round(sample[2])

		var/list/tile_data = coord_to_tile["[sx],[sy]"]
		if(!tile_data)
			continue

		var/list/settlement_data = generate_single_settlement(
			island_gen,
			bottom_left_corner,
			sx, sy,
			coord_to_tile
		)

		if(settlement_data)
			placed_settlements += list(settlement_data)
			break

	return placed_settlements

/datum/settlement_generator/proc/generate_single_settlement(datum/island_generator/island_gen, turf/bottom_left_corner, center_x, center_y, list/coord_to_tile)
	var/start_x = bottom_left_corner.x
	var/start_y = bottom_left_corner.y
	var/start_z = bottom_left_corner.z

	var/list/settlement_turfs = list()
	var/list/settlement_coords = list()

	for(var/dx = -settlement_radius to settlement_radius)
		for(var/dy = -settlement_radius to settlement_radius)
			if(dx * dx + dy * dy > settlement_radius * settlement_radius)
				continue

			var/tile_x = center_x + dx
			var/tile_y = center_y + dy
			var/list/tile_data = coord_to_tile["[tile_x],[tile_y]"]

			if(!tile_data)
				continue

			settlement_turfs += tile_data["turf"]
			settlement_coords["[tile_x],[tile_y]"] = tile_data

	if(settlement_turfs.len < 10)
		return null

	var/building_samples = island_gen.noise.poisson_disk_sampling(
		center_x - settlement_radius,
		center_x + settlement_radius,
		center_y - settlement_radius,
		center_y + settlement_radius,
		min_building_distance,
		min_building_distance * 1.5
	)

	var/list/placed_buildings = list()
	var/list/road_nodes = list()
	var/list/mob_spawn_points = list()
	var/list/building_bounds = list() //so we can build roads around

	for(var/list/sample in building_samples)
		if(placed_buildings.len >= max_building_attempts)
			break

		var/bx = round(sample[1])
		var/by = round(sample[2])

		if(!settlement_coords["[bx],[by]"])
			continue

		var/datum/settlement_building_template/template = pick(building_templates)
		var/list/building_data = try_place_building(
			template,
			bx, by,
			start_x, start_y, start_z,
			settlement_coords,
			island_gen
		)

		if(building_data)
			placed_buildings += list(building_data)

			if(building_data["road_node"])
				road_nodes += building_data["road_node"]

			if(building_data["mob_spawns"])
				mob_spawn_points += building_data["mob_spawns"]

			building_bounds += list(list(
				"x" = bx,
				"y" = by,
				"width" = template.width,
				"height" = template.height
			))

	if(!placed_buildings.len)
		return null

	var/turf/center_turf = locate(start_x + center_x, start_y + center_y, start_z)
	generate_road_network(center_turf, road_nodes, settlement_coords, start_x, start_y, start_z, building_bounds)

	if(length(mob_spawn_type))
		spawn_settlement_mobs(mob_spawn_points)

	return list(
		"center_x" = center_x,
		"center_y" = center_y,
		"buildings" = placed_buildings,
		"mob_spawns" = mob_spawn_points
	)

/datum/settlement_generator/proc/try_place_building(datum/settlement_building_template/template, bx, by, start_x, start_y, start_z, list/settlement_coords, datum/island_generator/island_gen)
	var/list/building_tiles = list()

	for(var/dx = 0 to template.width - 1)
		for(var/dy = 0 to template.height - 1)
			var/check_x = bx + dx
			var/check_y = by + dy
			var/list/tile_data = settlement_coords["[check_x],[check_y]"]

			if(!tile_data)
				return null

			building_tiles += tile_data["turf"]

	var/actual_z = start_z + template.z_offset
	var/turf/spawn_turf = locate(start_x + bx, start_y + by, actual_z)

	if(!spawn_turf)
		return null

	var/datum/map_template/building = new template.template_path()
	if(!building || !building.load(spawn_turf, centered = FALSE))
		return null

	var/turf/road_node = find_road_node(spawn_turf, template, start_z)
	var/list/mob_spawns = find_mob_spawn_points(spawn_turf, template, actual_z)

	return list(
		"template" = template,
		"x" = bx,
		"y" = by,
		"z_offset" = template.z_offset,
		"actual_z" = actual_z,
		"road_node" = road_node,
		"mob_spawns" = mob_spawns
	)

/datum/settlement_generator/proc/find_road_node(turf/building_origin, datum/settlement_building_template/template, level_z)
	for(var/x = 0 to template.width - 1)
		for(var/y = 0 to template.height - 1)
			var/turf/check = locate(building_origin.x + x, building_origin.y + y, level_z)
			if(!check)
				continue

			for(var/obj/effect/landmark/settlement_road_node/node in check)
				return check

	return locate(
		building_origin.x + round(template.width / 2),
		building_origin.y,
		level_z
	)

/datum/settlement_generator/proc/find_mob_spawn_points(turf/building_origin, datum/settlement_building_template/template, actual_z)
	var/list/spawn_points = list()

	var/z_min = actual_z
	var/z_max = actual_z

	for(var/x = 0 to template.width - 1)
		for(var/y = 0 to template.height - 1)
			for(var/z = z_min to z_max)
				var/turf/check = locate(building_origin.x + x, building_origin.y + y, z)
				if(!check)
					continue

				for(var/obj/effect/landmark/settlement_mob_spawn/marker in check)
					spawn_points += check
					qdel(marker)

	if(!spawn_points.len)
		var/mob_x = building_origin.x + round(template.width / 2)
		var/mob_y = building_origin.y + round(template.height / 2)
		var/turf/center_spawn = locate(mob_x, mob_y, actual_z)
		if(center_spawn)
			spawn_points += center_spawn

	return spawn_points

/datum/settlement_generator/proc/generate_road_network(turf/center, list/road_nodes, list/settlement_coords, start_x, start_y, start_z, list/building_bounds)
	for(var/turf/node in road_nodes)
		generate_road_path(center, node, settlement_coords, start_x, start_y, start_z, building_bounds)

/datum/settlement_generator/proc/generate_road_path(turf/from, turf/end, list/settlement_coords, start_x, start_y, start_z, list/building_bounds)
	var/list/path = get_smooth_path(from.x, from.y, end.x, end.y, start_x, start_y, building_bounds)

	for(var/coord in path)
		var/list/coords = splittext(coord, ",")
		var/px = text2num(coords[1])
		var/py = text2num(coords[2])

		var/rel_x = px - start_x
		var/rel_y = py - start_y
		var/list/tile_data = settlement_coords["[rel_x],[rel_y]"]

		var/is_water = !tile_data

		for(var/dx = -path_width to path_width)
			for(var/dy = -path_width to path_width)
				if(dx * dx + dy * dy > path_width * path_width)
					continue

				var/place_x = px + dx
				var/place_y = py + dy

				if(is_point_in_any_building(place_x - start_x, place_y - start_y, building_bounds))
					continue

				var/turf/T = locate(place_x, place_y, start_z)

				if(!T)
					continue

				var/turf_type = is_water ? pick(bridge_turfs) : pick(path_turfs)
				T.ChangeTurf(turf_type)

/datum/settlement_generator/proc/is_point_in_any_building(rel_x, rel_y, list/building_bounds)
	for(var/list/bounds in building_bounds)
		var/bx = bounds["x"]
		var/by = bounds["y"]
		var/width = bounds["width"]
		var/height = bounds["height"]

		if(rel_x >= bx - road_avoidance_padding && rel_x < bx + width + road_avoidance_padding)
			if(rel_y >= by - road_avoidance_padding && rel_y < by + height + road_avoidance_padding)
				return TRUE

	return FALSE

/datum/settlement_generator/proc/get_smooth_path(x1, y1, x2, y2, start_x, start_y, list/building_bounds)
	var/list/waypoints = list()
	waypoints += list(list(x1, y1))

	var/segments = round(sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2) / 10)
	segments = max(2, segments)

	for(var/i = 1 to segments - 1)
		var/progress = i / segments
		var/base_x = x1 + (x2 - x1) * progress
		var/base_y = y1 + (y2 - y1) * progress

		var/offset_x = rand(-max_path_deviation, max_path_deviation) * (1 - road_smoothness)
		var/offset_y = rand(-max_path_deviation, max_path_deviation) * (1 - road_smoothness)

		var/test_x = round(base_x + offset_x)
		var/test_y = round(base_y + offset_y)

		if(is_point_in_any_building(test_x - start_x, test_y - start_y, building_bounds))
			var/list/alternative = find_waypoint_around_buildings(test_x, test_y, start_x, start_y, building_bounds)
			if(alternative)
				test_x = alternative[1]
				test_y = alternative[2]

		waypoints += list(list(test_x, test_y))

	waypoints += list(list(x2, y2))

	var/list/full_path = list()
	for(var/i = 1 to waypoints.len - 1)
		var/list/point_a = waypoints[i]
		var/list/point_b = waypoints[i + 1]
		var/list/segment = get_line_between_points(point_a[1], point_a[2], point_b[1], point_b[2])
		full_path += segment

	return full_path

/datum/settlement_generator/proc/find_waypoint_around_buildings(x, y, start_x, start_y, list/building_bounds)
	var/list/offsets = list(
		list(5, 0), list(-5, 0), list(0, 5), list(0, -5),
		list(5, 5), list(-5, -5), list(5, -5), list(-5, 5)
	)

	for(var/list/offset in offsets)
		var/test_x = x + offset[1]
		var/test_y = y + offset[2]

		if(!is_point_in_any_building(test_x - start_x, test_y - start_y, building_bounds))
			return list(test_x, test_y)

	return null

/datum/settlement_generator/proc/get_line_between_points(x1, y1, x2, y2)
	var/list/line = list()
	var/dx = abs(x2 - x1)
	var/dy = abs(y2 - y1)
	var/sx = x1 < x2 ? 1 : -1
	var/sy = y1 < y2 ? 1 : -1
	var/err = dx - dy
	var/x = x1
	var/y = y1

	while(TRUE)
		line += "[x],[y]"

		if(x == x2 && y == y2)
			break

		var/e2 = 2 * err
		if(e2 > -dy)
			err -= dy
			x += sx
		if(e2 < dx)
			err += dx
			y += sy

	return line

/datum/settlement_generator/proc/spawn_settlement_mobs(list/spawn_points)
	for(var/turf/spawn_point in spawn_points)
		if(length(mob_spawn_type))
			var/path = pick(mob_spawn_type)
			new path(spawn_point)
