/datum/terrain_generation_job
	var/obj/effect/landmark/terrain_generation_marker/marker
	var/turf/bottom_left
	var/datum/cave_biome/cave_biome
	var/datum/island_biome/island_biome
	var/z_level

	var/status = GENERATION_STATUS_PENDING
	var/current_phase = ""
	var/progress = 0
	var/error = ""

	var/queued_time = 0
	var/start_time = 0
	var/completion_time = 0

/datum/island_data
	var/turf/bottom_left
	var/turf/top_right
	var/z_level
	var/island_size
	var/list/dock_anchors = list()
	var/island_id
	var/island_name // Human-readable name

/datum/island_data/New(turf/bl, size, _island_name)
	bottom_left = bl
	island_size = size
	z_level = bl.z + 2 // Island is always at z+2
	top_right = locate(bl.x + size - 1, bl.y + size - 1, z_level)
	island_id = "island_[bl.x]_[bl.y]_[z_level]_[world.time]"
	island_name = "[_island_name] Island #[length(SSterrain_generation.island_registry) + 1]"

/datum/ship_data
	var/turf/bottom_left
	var/turf/top_right
	var/z_level
	var/ship_size
	var/list/ship_anchors = list() // Turf locations for anchors (keyed by direction)
	var/datum/island_data/docked_island
	var/list/active_mirage_borders = list() // list of borders easier cleanup this way
	var/list/docked_boat_data

/datum/ship_data/New(turf/bl, size, z)
	bottom_left = bl
	ship_size = size
	z_level = z
	top_right = locate(bl.x + size - 1, bl.y + size - 1, z_level)

SUBSYSTEM_DEF(terrain_generation)
	name = "Terrain Generation"
	init_order = INIT_ORDER_TERRAIN
	flags = SS_NO_FIRE

	var/list/pending_generations = list()
	var/list/active_generations = list()
	var/list/completed_generations = list()

	// Configuration
	var/max_concurrent_generations = 1
	var/island_size = 98 // Actual island size (100x100 with 1-tile perimeter)
	var/perimeter_width = 1

	// Biome pools
	var/list/cave_biomes = list()
	var/list/island_biomes = list()

	// Mirage registry
	var/list/island_registry = list() // List of all islands
	var/list/ship_registry = list() // List of all ships

/datum/controller/subsystem/terrain_generation/Initialize()
	setup_biome_pools()
	generate_init_terrain()
	return ..()

/datum/controller/subsystem/terrain_generation/proc/setup_biome_pools()
	cave_biomes = subtypesof(/datum/cave_biome)
	island_biomes = subtypesof(/datum/island_biome)

/datum/controller/subsystem/terrain_generation/proc/generate_init_terrain()
	// Find all markers that should generate on init
	for(var/obj/effect/landmark/terrain_generation_marker/marker in world)
		if(marker.generate_on_init)
			log_world("Generating terrain at ([marker.x], [marker.y], [marker.z])...")

			var/cave_biome = marker.cave_biome_override || pick(cave_biomes)
			var/island_biome = marker.island_biome_override || pick(island_biomes)

			generate_terrain_sync(marker.loc, new cave_biome, new island_biome)

			qdel(marker)

			log_world("Terrain generation complete.")

/datum/controller/subsystem/terrain_generation/proc/generate_terrain_sync(turf/bottom_left, datum/cave_biome/cave_biome, datum/island_biome/island_biome)
	if(!bottom_left)
		return FALSE

	var/size = island_size
	bottom_left = get_step(bottom_left, EAST)
	bottom_left = get_step(bottom_left, NORTH)

	// Phase 1: Generate caves (z and z+1)
	var/datum/cave_generator/cave_gen = new(cave_biome, size, size)

	if(!cave_gen.generate(bottom_left))
		log_world("ERROR: Cave generation failed at ([bottom_left.x], [bottom_left.y], [bottom_left.z])")
		return FALSE

	// Phase 2: Generate island (z+2)
	var/turf/island_corner = locate(bottom_left.x, bottom_left.y, bottom_left.z + 2)
	if(!island_corner)
		log_world("ERROR: Could not locate island z-level at z+2")
		return FALSE

	var/datum/island_generator/island_gen = new(island_biome, size, size)

	if(!island_gen.generate(island_corner))
		log_world("ERROR: Island generation failed at ([island_corner.x], [island_corner.y], [island_corner.z])")
		return FALSE

	var/datum/island_data/island = new(bottom_left, size + (perimeter_width * 2), island_biome.name)
	island_registry += island

	return TRUE

/datum/controller/subsystem/terrain_generation/proc/queue_deferred_generation(turf/bottom_left, datum/cave_biome/cave_biome, datum/island_biome/island_biome, priority = FALSE)
	var/datum/terrain_generation_job/job = new()
	job.bottom_left = bottom_left
	job.cave_biome = cave_biome || pick(cave_biomes)
	job.island_biome = island_biome || pick(island_biomes)
	job.z_level = bottom_left.z
	job.queued_time = world.time

	if(priority)
		pending_generations.Insert(1, job)
	else
		pending_generations += job

	process_queue()

	return job

/datum/controller/subsystem/terrain_generation/proc/process_queue()
	while(active_generations.len < max_concurrent_generations && pending_generations.len)
		var/datum/terrain_generation_job/job = pending_generations[1]
		pending_generations.Cut(1, 2)

		start_generation(job)

/datum/controller/subsystem/terrain_generation/proc/start_generation(datum/terrain_generation_job/job)
	job.status = GENERATION_STATUS_ACTIVE
	job.start_time = world.time
	active_generations += job

	INVOKE_ASYNC(src, PROC_REF(generate_terrain_async), job)

/datum/controller/subsystem/terrain_generation/proc/generate_terrain_async(datum/terrain_generation_job/job)
	set waitfor = FALSE

	var/size = island_size + (perimeter_width * 2)

	try
		// Phase 1: Generate caves (z and z+1)
		job.current_phase = "Cave Generation"
		job.progress = 0

		var/datum/cave_generator/cave_gen = new(job.cave_biome, size, size)

		if(!cave_gen.generate_deferred(job.bottom_left, src, job))
			job.status = GENERATION_STATUS_FAILED
			job.error = "Cave generation failed"
			finalize_generation(job)
			return

		job.progress = 50

		// Phase 2: Generate island (z+2)
		job.current_phase = "Island Generation"

		var/turf/island_corner = locate(job.bottom_left.x, job.bottom_left.y, job.z_level + 2)
		if(!island_corner)
			job.status = GENERATION_STATUS_FAILED
			job.error = "Could not locate island z-level"
			finalize_generation(job)
			return

		var/datum/island_generator/island_gen = new(job.island_biome, size, size)

		if(!island_gen.generate_deferred(island_corner, src, job))
			job.status = GENERATION_STATUS_FAILED
			job.error = "Island generation failed"
			finalize_generation(job)
			return

		job.progress = 100
		job.status = GENERATION_STATUS_COMPLETE

	catch(var/exception/e)
		job.status = GENERATION_STATUS_FAILED
		job.error = "Exception: [e]"
		log_world("ERROR: Terrain generation exception: [e]")

	finalize_generation(job)

/datum/controller/subsystem/terrain_generation/proc/finalize_generation(datum/terrain_generation_job/job)
	job.completion_time = world.time
	active_generations -= job
	completed_generations += job

	// Clean up marker if it exists
	if(job.marker)
		qdel(job.marker)
		job.marker = null

	// Log completion
	var/duration = (job.completion_time - job.start_time) / 10
	if(job.status == GENERATION_STATUS_COMPLETE)
		log_world("Terrain generation completed at ([job.bottom_left.x], [job.bottom_left.y], [job.z_level]) in [duration]s")
	else
		log_world("Terrain generation FAILED at ([job.bottom_left.x], [job.bottom_left.y], [job.z_level]): [job.error]")

	// Process next in queue
	process_queue()

/datum/controller/subsystem/terrain_generation/proc/trigger_deferred_generation(obj/effect/landmark/terrain_generation_marker/marker)
	if(!marker || marker.generate_on_init)
		return FALSE

	var/cave_biome = marker.cave_biome_override || pick(cave_biomes)
	var/island_biome = marker.island_biome_override || pick(island_biomes)

	var/datum/terrain_generation_job/job = queue_deferred_generation(marker.loc, cave_biome, island_biome)
	job.marker = marker

	return TRUE

/datum/controller/subsystem/terrain_generation/proc/get_generation_status(turf/location)
	for(var/datum/terrain_generation_job/job in active_generations + pending_generations + completed_generations)
		if(is_location_in_generation_area(location, job))
			return job
	return null

/datum/controller/subsystem/terrain_generation/proc/is_location_in_generation_area(turf/location, datum/terrain_generation_job/job)
	if(!location || !job.bottom_left)
		return FALSE

	var/size = island_size + (perimeter_width * 2)

	if(location.x >= job.bottom_left.x && location.x < job.bottom_left.x + size)
		if(location.y >= job.bottom_left.y && location.y < job.bottom_left.y + size)
			if(location.z >= job.z_level && location.z <= job.z_level + 2)
				return TRUE
	return FALSE

/datum/controller/subsystem/terrain_generation/proc/register_island(datum/terrain_generation_job/job)
	var/datum/island_data/island = new(job.bottom_left, island_size + (perimeter_width * 2), job.island_biome.name)
	island_registry += island
	return island

/datum/controller/subsystem/terrain_generation/proc/register_ship(turf/bottom_left, size)
	if(!bottom_left)
		return null

	var/datum/ship_data/ship = new(bottom_left, size, bottom_left.z)
	ship_registry += ship

	return ship

/datum/controller/subsystem/terrain_generation/proc/spawn_docking_boat(datum/ship_data/ship, datum/island_data/island, direction)
	var/turf/shore_turf = find_shore_location(island, direction)
	if(!shore_turf)
		log_world("ERROR: Could not find shore location for boat spawn")
		return null

	var/offset_distance = rand(3, 4)
	var/turf/boat_spawn = shore_turf
	for(var/i = 1 to offset_distance)
		boat_spawn = get_step(boat_spawn, direction)
		if(!boat_spawn)
			log_world("ERROR: Could not offset boat spawn location")
			return null

	var/datum/map_template/island_boat/boat_template = new()

	if(!boat_template || !boat_template.width || !boat_template.height)
		log_world("ERROR: Failed to load boat template")
		return null

	var/turf/center_turf = locate(
		boat_spawn.x - round(boat_template.width / 2),
		boat_spawn.y - round(boat_template.height / 2),
		boat_spawn.z
	)

	if(!center_turf)
		log_world("ERROR: Could not calculate center for boat")
		return null

	var/list/loaded_bounds = boat_template.load(center_turf, FALSE)

	if(!loaded_bounds || !loaded_bounds.len)
		log_world("ERROR: Failed to load boat template at location")
		return null

	var/list/boat_data = collect_boat_objects(boat_template, center_turf)

	return boat_data

/datum/controller/subsystem/terrain_generation/proc/collect_boat_objects(datum/map_template/template, turf/center_turf)
	var/list/boat_data = list(
		"objects" = list(),
		"turfs" = list()
	)

	for(var/turf/place_on as anything in template.get_affected_turfs(center_turf, centered = TRUE))
		if(istype(place_on, /turf/open/water) || istype(place_on, /turf/open/floor/sand))
			for(var/obj/structure/O in place_on.contents)
				boat_data["objects"] += O
			continue

		boat_data["turfs"] += place_on

		for(var/obj/effect/overlay/water/water in place_on.contents)
			qdel(water)

		for(var/obj/structure/O in place_on.contents)
			boat_data["objects"] += O

	return boat_data

/datum/controller/subsystem/terrain_generation/proc/cleanup_docking_boat(list/boat_data)
	if(!boat_data || !boat_data.len)
		return

	for(var/obj/O in boat_data["objects"])
		if(!QDELETED(O))
			qdel(O)

	for(var/turf/T in boat_data["turfs"])
		if(!QDELETED(T))
			T.ChangeTurf(/turf/open/water/ocean)

	boat_data["objects"] = list()
	boat_data["turfs"] = list()

	log_world("Cleaned up docking boat")

/datum/controller/subsystem/terrain_generation/proc/find_shore_location(datum/island_data/island, direction)
	// Get edge turfs based on direction
	var/list/edge_turfs = get_edge_turfs(island.bottom_left, island.island_size, island.z_level, direction, FALSE)

	if(!edge_turfs.len)
		return null

	// Cast lines from edge turfs to find sand/shore tiles
	var/opposite_dir = turn(direction, 180) // Direction toward island interior

	for(var/turf/edge_turf in edge_turfs)
		var/turf/current = edge_turf
		var/distance = 0

		for(var/i = 1 to 30)
			current = get_step(current, opposite_dir)
			if(!current)
				break

			distance++
			if(istype(current, /turf/open/floor/sand))
				if(distance >= 10)
					return current
				break

	return edge_turfs[round(edge_turfs.len / 2)]

/datum/controller/subsystem/terrain_generation/proc/dock_ship_to_island(datum/ship_data/ship, datum/island_data/island, mirage_range = world.view)
	if(!ship || !island)
		return FALSE

	if(ship.docked_island)
		undock_ship(ship)

	var/ship_direction = NORTH
	var/island_direction = SOUTH

	var/list/ship_edge_turfs = get_edge_turfs(ship.bottom_left, ship.ship_size, ship.z_level, ship_direction, TRUE)
	var/list/island_edge_turfs = get_edge_turfs(island.bottom_left, island.island_size, island.z_level, island_direction, FALSE)

	if(!ship_edge_turfs.len || !island_edge_turfs.len)
		log_world("ERROR: Could not get edge turfs for docking")
		return FALSE

	for(var/turf/ship_turf in ship_edge_turfs)
		var/index = ship_edge_turfs.Find(ship_turf)
		var/turf/island_turf = island_edge_turfs[min(index, island_edge_turfs.len)]

		var/datum/component/mirage_border/ship_to_island = ship_turf.AddComponent(\
			/datum/component/mirage_border,\
			island_turf,\
			ship_direction,\
			mirage_range\
		)
		ship.active_mirage_borders += ship_to_island
		ship.active_mirage_borders += ship_turf

	for(var/turf/island_turf in island_edge_turfs)
		var/index = island_edge_turfs.Find(island_turf)
		var/turf/ship_turf = ship_edge_turfs[min(index, ship_edge_turfs.len)]

		var/datum/component/mirage_border/island_to_ship = island_turf.AddComponent(\
			/datum/component/mirage_border,\
			ship_turf,\
			island_direction,\
			mirage_range\
		)
		ship.active_mirage_borders += island_to_ship
		ship.active_mirage_borders += island_turf

	// Spawn docking boat on island
	ship.docked_boat_data = spawn_docking_boat(ship, island, island_direction)
	ship.docked_island = island

	log_world("Docked ship at z=[ship.z_level] to island at z=[island.z_level] with boat")
	return TRUE

/datum/controller/subsystem/terrain_generation/proc/get_edge_turfs(turf/bottom_left, size, z_level, direction, is_ship = FALSE)
	var/list/turfs = list()

	var/offset = 0
	if(is_ship) //ship bounds include the walls so we offset by 1
		offset++

	var/edge_length = size - 2 //this means the actual area we check is not the full 100

	switch(direction)
		if(NORTH)
			var/edge_y = bottom_left.y + size - 1 - offset
			var/start_x = bottom_left.x + offset
			for(var/x = start_x to start_x + edge_length - 1)
				var/turf/T = locate(x, edge_y, z_level)
				if(T)
					turfs += T

		if(SOUTH)
			var/edge_y = bottom_left.y + offset
			var/start_x = bottom_left.x + offset
			for(var/x = start_x to start_x + edge_length - 1)
				var/turf/T = locate(x, edge_y, z_level)
				if(T)
					turfs += T

		if(EAST)
			var/edge_x = bottom_left.x + size - 1 - offset
			var/start_y = bottom_left.y + offset
			for(var/y = start_y to start_y + edge_length - 1)
				var/turf/T = locate(edge_x, y, z_level)
				if(T)
					turfs += T

		if(WEST)
			var/edge_x = bottom_left.x + offset
			var/start_y = bottom_left.y + offset
			for(var/y = start_y to start_y + edge_length - 1)
				var/turf/T = locate(edge_x, y, z_level)
				if(T)
					turfs += T

	return turfs

/datum/controller/subsystem/terrain_generation/proc/undock_ship(datum/ship_data/ship)
	if(!ship)
		return FALSE

	// Clean up mirage borders
	for(var/i = 1; i <= ship.active_mirage_borders.len; i++)
		var/entry = ship.active_mirage_borders[i]
		if(istype(entry, /datum/component/mirage_border))
			var/datum/component/mirage_border/MB = entry
			qdel(MB)
		else if(isturf(entry))
			var/turf/T = entry
			var/datum/component/mirage_border/MB = T.GetComponent(/datum/component/mirage_border)
			if(MB)
				qdel(MB)

	ship.active_mirage_borders.Cut()

	// Clean up docking boat
	if(ship.docked_boat_data)
		cleanup_docking_boat(ship.docked_boat_data)
		ship.docked_boat_data = null

	ship.docked_island = null

	log_world("Undocked ship at z=[ship.z_level]")
	return TRUE

/datum/controller/subsystem/terrain_generation/proc/get_island_by_id(island_id)
	for(var/datum/island_data/island in island_registry)
		if(island.island_id == island_id)
			return island
	return null

/datum/controller/subsystem/terrain_generation/proc/get_all_islands()
	return island_registry.Copy()

/datum/controller/subsystem/terrain_generation/proc/get_ship_at_location(turf/T)
	if(!T)
		return null

	for(var/datum/ship_data/ship in ship_registry)
		if(T.x >= ship.bottom_left.x && T.x <= ship.top_right.x)
			if(T.y >= ship.bottom_left.y && T.y <= ship.top_right.y)
				if(T.z >= ship.z_level && T.z <= ship.z_level + 3)
					return ship

	return null

/datum/controller/subsystem/terrain_generation/proc/get_island_at_location(turf/T)
	if(!T)
		return null

	for(var/datum/island_data/island in island_registry)
		if(T.x >= island.bottom_left.x && T.x <= island.top_right.x)
			if(T.y >= island.bottom_left.y && T.y <= island.top_right.y)
				if(T.z == island.z_level)
					return island

	return null

/client/proc/list_all_ships_and_islands()
	set name = "List Ships and Islands"
	set category = "Debug"

	to_chat(src, "<b>==== SHIPS ====</b>")
	for(var/datum/ship_data/ship in SSterrain_generation.ship_registry)
		var/docked = ship.docked_island ? "DOCKED to [ship.docked_island.island_name]" : "NOT DOCKED"
		to_chat(src, "Ship at z=[ship.z_level] ([ship.bottom_left.x],[ship.bottom_left.y]) - [docked]")

	to_chat(src, "<b>==== ISLANDS ====</b>")
	for(var/datum/island_data/island in SSterrain_generation.island_registry)
		to_chat(src, "[island.island_name] at z=[island.z_level] ([island.bottom_left.x],[island.bottom_left.y]) ID: [island.island_id]")
