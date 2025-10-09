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


// Generation job datum
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


// Generation marker
/obj/effect/landmark/terrain_generation_marker
	name = "terrain generation marker"
	desc = "Marks where terrain should be generated. Bottom-left corner including perimeter."
	icon = 'icons/effects/effects.dmi'
	icon_state = "x2"
	alpha = 128

	var/generate_on_init = TRUE
	var/datum/cave_biome/cave_biome_override = null
	var/datum/island_biome/island_biome_override = null

/obj/effect/landmark/terrain_generation_marker/Initialize(mapload)
	. = ..()
	if(!generate_on_init)
		// Make visible for deferred generation
		alpha = 255

/obj/effect/landmark/terrain_generation_marker/attack_hand(mob/user)
	. = ..()
	if(!generate_on_init)
		to_chat(user, span_notice("Triggering terrain generation..."))
		if(SSterrain_generation.trigger_deferred_generation(src))
			to_chat(user, span_notice("Generation queued!"))
		else
			to_chat(user, span_warning("Failed to queue generation."))

/obj/effect/landmark/terrain_generation_marker/deferred
	generate_on_init = FALSE
