SUBSYSTEM_DEF(dungeon_generator)
	name = "Matthios Creation"
	wait = 1 SECONDS

	init_order = INIT_ORDER_DUNGEON
	runlevels = RUNLEVEL_GAME | RUNLEVEL_INIT | RUNLEVEL_LOBBY
	lazy_load = FALSE

	var/list/parent_types = list()
	var/list/created_types = list()
	var/list/markers = list()
	var/list/placed_types = list()

	var/dungeon_z = -1 // The definite z level of the first level

	var/multilevel_dungeons = FALSE  // Toggle for multi-level generation
	var/max_delve_levels = 2        // Maximum dungeon depth
	var/list/dungeon_levels = list() // Track z-levels for each delve level
	var/list/delve_entries = list()  // Pre-generated entry points for each level
	var/list/delve_descent = list()  // Pre-generated entry points for each level

	var/list/descent_objects = list() // Track descent objects by level
	var/list/level_entries = list()   // Track all entries by delve level

	var/created_since = 0
	var/descent_since = 0
	var/unlinked_dungeon_length = 0

	/// helper -> depth of the room that owns it (rooms placed from it get this + 1)
	var/list/marker_depths = list()
	/// Room depth (rooms away from the start) at which a room counts as "fully far out" (factor 1.0)
	var/depth_full_scale = 12
	/// Extra depth added per delve level, so deeper delve levels count as further out
	var/depth_per_delve_level = 6
	/// How hard rare rooms are pushed outward. 0 = no effect.
	/// A room with remoteness r gets weight multiplier 1 + strength * r * (2 * depth_factor - 1)
	var/rare_depth_strength = 1.5
	/// Highest rarity value among all concrete templates, cached when created_types is built
	var/max_rarity = 1

	var/list/loot_spawners = list()
	/// Total loot value spread across the whole dungeon
	var/loot_budget = 600
	/// Budget left over after the last distribution
	var/loot_remaining = 0
	/// Spawner weight = spawn_weight * (1 + depth_factor * loot_depth_bias). Higher = loot clusters further out.
	var/loot_depth_bias = 3
	var/loot_distributed = FALSE

/datum/controller/subsystem/dungeon_generator/Initialize(start_timeofday)
	unlinked_dungeon_length = length(GLOB.unlinked_dungeon_entries)

	if(multilevel_dungeons)
		setup_multilevel_dungeons()

	while(length(markers))
		for(var/obj/effect/dungeon_directional_helper/helper as anything in markers)
			markers -= helper
			if(!get_turf(helper))
				marker_depths -= helper
				continue
			if(dungeon_z == -1)
				dungeon_z = helper.z // this shouldn't ever fail i think
			find_soulmate(helper.dir, get_turf(helper), helper)
			marker_depths -= helper

	distribute_loot()
	return ..()

/datum/controller/subsystem/dungeon_generator/proc/setup_multilevel_dungeons()
	for(var/level = 1; level <= max_delve_levels; level++)
		delve_entries["[level]"] = rand(2, 4)
		delve_descent["[level]"] = rand(2, 4)
		dungeon_levels["[level]"] = list()

/datum/controller/subsystem/dungeon_generator/fire(resumed)
	if(!length(markers))
		// Generation finished loot is good to spawn now
		if(!loot_distributed)
			distribute_loot()
		return

	var/current_run = 0
	for(var/obj/effect/dungeon_directional_helper/helper as anything in markers)
		if(current_run >= 4)
			return
		markers -= helper
		if(!get_turf(helper))
			marker_depths -= helper
			continue
		find_soulmate(helper.dir, get_turf(helper), helper)
		marker_depths -= helper
		if(TICK_CHECK_LOW)
			return
		current_run++

/datum/controller/subsystem/dungeon_generator/proc/setup_template_caches()
	if(!length(parent_types))
		for(var/datum/map_template/dungeon/path as anything in subtypesof(/datum/map_template/dungeon))
			if(!IS_ABSTRACT(path))
				continue
			if(!initial(path.type_weight))
				continue
			parent_types += path
			parent_types[path] = initial(path.type_weight)

	if(!length(created_types))
		for(var/datum/map_template/dungeon/path as anything in subtypesof(/datum/map_template/dungeon))
			if(IS_ABSTRACT(path))
				continue
			var/datum/map_template/dungeon/template = new path
			created_types[template] = template.rarity
		max_rarity = 1
		for(var/datum/map_template/dungeon/template in created_types)
			max_rarity = max(max_rarity, template.rarity || 1)

/// 0..1 for how far out a room is. Combines room depth with delve level.
/datum/controller/subsystem/dungeon_generator/proc/get_depth_factor(room_depth, z_level)
	var/effective_depth = room_depth + ((get_delve_level(z_level) || 0) * depth_per_delve_level)
	return clamp(effective_depth / max(depth_full_scale, 1), 0, 1)

/// Weight of a template at a given depth. 0 means it cannot appear here.
/// Common rooms (rarity == max_rarity) are unaffected; the rarer a room is, the more it
/// is suppressed near the start and boosted far out.
/datum/controller/subsystem/dungeon_generator/proc/get_depth_weight(datum/map_template/dungeon/template, room_depth, depth_factor)
	if(room_depth < template.min_depth)
		return 0
	var/base_weight = template.rarity || 1
	var/remoteness = 1 - clamp(base_weight / max_rarity, 0, 1)
	var/multiplier = 1 + rare_depth_strength * remoteness * ((depth_factor * 2) - 1)
	return base_weight * max(multiplier, 0.05)

/// Builds template -> weight.
/// only_picked = TRUE keeps just subtypes of picked_type; FALSE keeps everything except picked_type and entries.
/datum/controller/subsystem/dungeon_generator/proc/build_weighted_templates(room_depth, depth_factor, picked_type, only_picked, apply_depth = TRUE)
	var/list/result = list()
	for(var/datum/map_template/dungeon/template in created_types)
		if(only_picked)
			if(!istype(template, picked_type))
				continue
		else if(istype(template, picked_type) || istype(template, /datum/map_template/dungeon/entry))
			continue
		var/weight = template.rarity || 1
		if(apply_depth)
			weight = get_depth_weight(template, room_depth, depth_factor)
		weight *= get_occurrence_multiplier(template)
		if(weight <= 0)
			continue
		result[template] = weight
	return result

/// 0 once a template has hit its placement limit, otherwise a falloff based on how many times it's been placed.
/datum/controller/subsystem/dungeon_generator/proc/get_occurrence_multiplier(datum/map_template/dungeon/template)
	var/count = placed_types[template.type] || 0
	var/limit = template.unique ? 1 : template.max_occurrences
	if(limit && count >= limit)
		return 0
	if(template.repeat_falloff && count)
		return (1 - clamp(template.repeat_falloff, 0, 1)) ** count
	return 1

/// Weighted pick from an assoc list of thing -> numeric weight. Does not remove the result.
/datum/controller/subsystem/dungeon_generator/proc/pick_weighted_key(list/weighted)
	if(!length(weighted))
		return null
	var/total = 0
	for(var/key in weighted)
		total += weighted[key]
	var/chosen = rand() * total
	for(var/key in weighted)
		chosen -= weighted[key]
		if(chosen <= 0)
			return key
	return weighted[length(weighted)] ? weighted[length(weighted)] : null

/// Keeps drawing templates (without replacement) until one fits. Returns list(template, turf) or null.
/datum/controller/subsystem/dungeon_generator/proc/place_from_candidates(list/candidates, direction, turf/creator)
	while(length(candidates))
		var/datum/map_template/dungeon/template = pick_weighted_key(candidates)
		if(!template)
			return null
		candidates -= template

		var/turf/true_spawn = calculate_spawn_position(template, direction, creator)
		if(!true_spawn || !validate_spawn_area(template, true_spawn))
			continue

		if(!template.load(true_spawn))
			continue

		return list(template, true_spawn)
	return null

/// Bookkeeping after a room is loaded: counters, depth for its helpers, registration of its loot spawners.
/datum/controller/subsystem/dungeon_generator/proc/register_placed_room(datum/map_template/dungeon/template, turf/true_spawn, room_depth)
	placed_types |= template.type
	placed_types[template.type]++

	for(var/turf/room_turf in template.get_affected_turfs(true_spawn))
		for(var/obj/effect/dungeon_directional_helper/helper in room_turf)
			marker_depths[helper] = room_depth
		for(var/obj/effect/dungeon_loot_spawner/spawner in room_turf)
			spawner.depth = room_depth
			loot_spawners |= spawner

/datum/controller/subsystem/dungeon_generator/proc/find_soulmate(direction, turf/creator, obj/effect/dungeon_directional_helper/looking_for_love)
	creator = get_step(creator, direction)
	if(!creator)
		return
	if(creator.type != /turf/closed/dungeon_void)
		return

	// Determine current delve level
	var/current_delve_level = get_delve_level(creator.z)

	//depth of the room that owns this helper + 1
	var/room_depth = (marker_depths[looking_for_love] || 0) + 1
	var/depth_factor = get_depth_factor(room_depth, creator.z)

	switch(direction)
		if(NORTH)
			direction = SOUTH
		if(SOUTH)
			direction = NORTH
		if(EAST)
			direction = WEST
		if(WEST)
			direction = EAST

	setup_template_caches()

	var/picked_type = pickweight(parent_types)

	// Handle multi-level dungeon logic
	if(multilevel_dungeons && current_delve_level > 0)
		// Check if we should spawn a descent
		if(descent_since > 30)
			if(should_spawn_descent(current_delve_level))
				picked_type = /datum/map_template/dungeon/descent
		// Modify entry spawn chance based on remaining entries for this level
		else if(unlinked_dungeon_length > 0 && delve_entries["[current_delve_level]"] > 0)
			if(created_since > 30)
				if(prob(10 + created_since))
					picked_type = /datum/map_template/dungeon/entry
	else if(unlinked_dungeon_length > 0)
		if(created_since > 30)
			if(prob(10 + created_since))
				picked_type = /datum/map_template/dungeon/entry

	// Entries / descents are forced picks; don't let depth scaling or min_depth exclude them.
	var/special_pick = (picked_type == /datum/map_template/dungeon/entry || picked_type == /datum/map_template/dungeon/descent)

	if(try_pickedtype_first(picked_type, direction, creator, looking_for_love, current_delve_level, room_depth, depth_factor, special_pick))
		return

	// Fallback: anything that isn't the picked type or an entry, weighted by depth.
	if(!GET_TURF_ABOVE(creator))
		message_admins("[ADMIN_JMP(creator)] A dungeon piece was set to spawn on a top level z. This is not intended, there is a bad template.")
		return

	var/list/candidates = build_weighted_templates(room_depth, depth_factor, picked_type, FALSE, TRUE)
	var/list/placed = place_from_candidates(candidates, direction, creator)
	if(!placed)
		return

	var/datum/map_template/dungeon/template = placed[1]
	var/turf/true_spawn = placed[2]
	created_since++
	descent_since++
	register_placed_room(template, true_spawn, room_depth)

	// Apply delve modifiers if multi-level dungeons are enabled
	if(multilevel_dungeons && current_delve_level > 0)
		enhance_dungeon_area(template, true_spawn, current_delve_level)

/datum/controller/subsystem/dungeon_generator/proc/try_pickedtype_first(picked_type, direction, turf/creator, obj/effect/dungeon_directional_helper/looking_for_love, delve_level = 0, room_depth = 1, depth_factor = 0, special_pick = FALSE)
	var/list/candidates = build_weighted_templates(room_depth, depth_factor, picked_type, TRUE, !special_pick)
	var/list/placed = place_from_candidates(candidates, direction, creator)
	if(!placed)
		return FALSE

	var/datum/map_template/dungeon/template = placed[1]
	var/turf/true_spawn = placed[2]

	created_since++
	register_placed_room(template, true_spawn, room_depth)

	// Handle special cases for multi-level dungeons
	if(multilevel_dungeons)
		if(picked_type == /datum/map_template/dungeon/entry && delve_level > 0)
			delve_entries["[delve_level]"]--

	if(picked_type == /datum/map_template/dungeon/entry)
		created_since = 0
		unlinked_dungeon_length--

	if(picked_type == /datum/map_template/dungeon/descent)
		descent_since = 0
		delve_descent["[delve_level]"]--

	// Apply delve modifiers if multi-level dungeons are enabled
	if(multilevel_dungeons && delve_level > 0)
		enhance_dungeon_area(template, true_spawn, delve_level)

	return TRUE

/datum/controller/subsystem/dungeon_generator/proc/calculate_spawn_position(datum/map_template/dungeon/template, direction, turf/creator)
	var/turf/true_spawn
	switch(direction)
		if(WEST)
			if(!template.west_offset)
				return null
			if(creator.y - template.west_offset < 0)
				return null
			var/turf/turf = locate(creator.x, creator.y - template.west_offset, creator.z)
			if(turf?.type != /turf/closed/dungeon_void)
				return null
			var/turf/turf2 = locate(creator.x + template.width, creator.y - template.east_offset, creator.z)
			if(turf2?.type != /turf/closed/dungeon_void)
				return null
			true_spawn = get_offset_target_turf(creator, 0, -(template.west_offset))

		if(NORTH)
			if(!template.north_offset)
				return null
			if(creator.x - template.north_offset < 0)
				return null
			if(creator.y - template.height < 0)
				return null
			var/turf/turf = locate(creator.x - template.north_offset - 1, creator.y + template.height, creator.z)
			if(turf?.type != /turf/closed/dungeon_void)
				return null
			var/turf/turf2 = locate(creator.x -(template.north_offset - 1) + template.width, creator.y + template.height, creator.z)
			if(turf2?.type != /turf/closed/dungeon_void)
				return null
			true_spawn = get_offset_target_turf(creator, -(template.north_offset), -(template.height-1))

		if(SOUTH)
			if(!template.south_offset)
				return null
			if(creator.y - template.south_offset < 0)
				return null
			var/turf/turf = locate(creator.x, creator.y + template.height, creator.z)
			if(turf?.type != /turf/closed/dungeon_void)
				return null
			var/turf/turf2 = locate(creator.x + template.width - template.south_offset, creator.y + template.height, creator.z)
			if(turf2?.type != /turf/closed/dungeon_void)
				return null
			true_spawn = get_offset_target_turf(creator, -template.south_offset, 0)

		if(EAST)
			if(!template.east_offset)
				return null
			if(creator.y - template.east_offset < 0)
				return null
			if(creator.x - template.width < 0)
				return null
			var/turf/turf = locate(creator.x - (template.width-1), creator.y - template.east_offset, creator.z)
			if(turf?.type != /turf/closed/dungeon_void)
				return null
			var/turf/turf2 = locate(creator.x, creator.y - template.east_offset, creator.z)
			if(turf2?.type != /turf/closed/dungeon_void)
				return null
			true_spawn = get_offset_target_turf(creator, -(template.width-1), -template.east_offset)

	return true_spawn

/datum/controller/subsystem/dungeon_generator/proc/validate_spawn_area(datum/map_template/dungeon/template, turf/true_spawn)
	if(true_spawn.x + template.width > world.maxx)
		return FALSE
	if(true_spawn.y + template.height > world.maxy)
		return FALSE

	var/list/turfs = template.get_affected_turfs(true_spawn)
	for(var/turf/list_turf in turfs)
		if(list_turf.type != /turf/closed/dungeon_void)
			return FALSE
	return TRUE

/datum/controller/subsystem/dungeon_generator/proc/get_delve_level(z_level)
	// Each delve level spans 2 z-levels
	// Returns 0 for surface/non-dungeon levels
	if(!multilevel_dungeons)
		return

	return SSmapping.get_delve(z_level)

/datum/controller/subsystem/dungeon_generator/proc/should_spawn_descent(current_level)
	if(!multilevel_dungeons)
		return FALSE
	if(current_level >= max_delve_levels) // No descents on the last level
		return FALSE
	if(delve_descent["[current_level]"] <= 0) // No more entries needed for next level
		return FALSE

	// Chance to spawn a descent - higher chance later in generation
	return prob(15 + (descent_since * 2))

/datum/controller/subsystem/dungeon_generator/proc/enhance_dungeon_area(datum/map_template/dungeon/template, turf/spawn_location, delve_level)
	if(!multilevel_dungeons || delve_level <= 0)
		return

	var/list/affected_turfs = template.get_affected_turfs(spawn_location)

	// Find and enhance all mobs in the area
	for(var/turf/T in affected_turfs)
		for(var/mob/M in T.contents)
			if(isliving(M))
				SSmobs.enhance_mob(M, delve_level)

/// Spreads loot_budget across the registered spawners. Spawners are never deleted, they just
/// stop accepting items once full, so this can be re-run after clear_loot().
/// Returns the total loot value placed this run.
/datum/controller/subsystem/dungeon_generator/proc/distribute_loot()
	loot_distributed = TRUE
	loot_remaining = loot_budget

	var/list/candidates = list()
	for(var/obj/effect/dungeon_loot_spawner/spawner as anything in loot_spawners)
		if(QDELETED(spawner) || !spawner.can_accept_loot())
			continue
		candidates[spawner] = spawner.spawn_weight * (1 + get_depth_factor(spawner.depth, spawner.z) * loot_depth_bias)

	while(loot_remaining > 0 && length(candidates))
		var/obj/effect/dungeon_loot_spawner/spawner = pick_weighted_key(candidates)
		if(!spawner)
			break
		// Item has to fit both the spawner's remaining capacity and what's left of the global budget.
		var/item_path = spawner.pick_loot(min(loot_remaining, spawner.get_remaining_value()))
		if(!item_path)
			candidates -= spawner
			continue
		loot_remaining -= spawner.spawn_loot(item_path)
		if(!spawner.can_accept_loot())
			candidates -= spawner
		CHECK_TICK

	var/spent = loot_budget - loot_remaining
	log_world("Dungeon loot distributed: [spent]/[loot_budget] value across [length(loot_spawners)] spawners.")
	return spent

///Reset every spawner's used value and hand out a fresh budget. Should probably only ever be used for debugging/events?
/datum/controller/subsystem/dungeon_generator/proc/regenerate_loot()
	for(var/obj/effect/dungeon_loot_spawner/spawner as anything in loot_spawners)
		if(QDELETED(spawner))
			loot_spawners -= spawner
			continue
		spawner.used_value = 0
	return distribute_loot()
