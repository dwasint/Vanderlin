/datum/building_datum
	var/mob/camera/strategy_controller/master
	var/name = "Generic Name"
	var/desc = "Generic Desc"
	///this is our template id
	var/building_template
	var/mutable_appearance/generated_MA
	var/list/resource_cost = list(
		"Stone" = 0,
		"Wood" = 0,
		"Gems" = 0,
		"Ores" = 0,
		"Ingots" = 0,
		"Coal" = 0,
		"Grain" = 0,
		"Meat" = 0,
		"Vegetable" = 0,
		"Fruit" = 0,
	)

	var/list/needed_broken_turfs = list()

	var/build_time = 40 SECONDS
	var/workers_required = 1
	var/current_workers = 0
	var/turf/center_turf

	var/building_node_path
	var/building_right_now = FALSE

/datum/building_datum/New(mob/camera/strategy_controller/created, turf/turf)
	. = ..()
	generate_preview()
	if(turf)
		if(!try_place_building(created, turf))
			return INITIALIZE_HINT_QDEL
		master = created
		master.building_requests |= src

/datum/building_datum/proc/generate_preview()
	var/datum/map_template/template = SSmapping.map_templates[building_template]
	generated_MA = mutable_appearance()
	var/turf/T = get_turf(usr)
	for(var/turf/place_on as anything in template.get_affected_turfs(T,centered = TRUE))
		var/offset_x = T.x - place_on.x
		var/offset_y = T.y - place_on.y

		var/mutable_appearance/placement_node = mutable_appearance('icons/effects/alphacolors.dmi', "red")
		placement_node.pixel_x = offset_x * 32
		placement_node.pixel_y = offset_y * 32
		generated_MA.add_overlay(placement_node)

/datum/building_datum/proc/try_place_building(mob/camera/strategy_controller/user, turf/placed_turf)
	var/has_cost = FALSE
	for(var/resource in resource_cost)
		if(resource_cost[resource])
			has_cost = TRUE
			break

	if(has_cost && !user.resource_stockpile)
		return FALSE
	if(has_cost)
		if(!user.resource_stockpile?.has_resources(resource_cost))
			return

		user.resource_stockpile.remove_resources(resource_cost)


	var/datum/map_template/template = SSmapping.map_templates[building_template]
	var/list/turfs = template.get_affected_turfs(placed_turf,centered = TRUE)
	center_turf = placed_turf
	for(var/turf/turf in turfs)
		if(!isclosedturf(turf))
			continue
		needed_broken_turfs |= turf
		if(!turf.break_overlay)
			create_turf_break_overlay(turf)

	return TRUE

/datum/building_datum/proc/try_work_on(mob/living/worker)
	if(!worker.controller_mind)
		return FALSE
	if(length(needed_broken_turfs))
		for(var/turf/turf in needed_broken_turfs)
			if(!length(get_path_to(worker, turf, /turf/proc/Distance, 32 + 1, 250,1)))
				continue
			worker.controller_mind.set_current_task(/datum/work_order/break_turf, turf, src)
			needed_broken_turfs -= turf
			return TRUE

	if(current_workers >= workers_required)
		return FALSE

	current_workers++
	worker.controller_mind.set_current_task(/datum/work_order/construct_building, src)
	return TRUE

/datum/building_datum/proc/construct_building()
	if(building_right_now)
		return
	building_right_now = TRUE

	var/datum/map_template/template = SSmapping.map_templates[building_template]
	template.load(center_turf, TRUE)

	for(var/turf/place_on as anything in template.get_affected_turfs(center_turf ,centered = TRUE))
		for(var/obj/effect/effect in place_on.contents)
			if(!istype(effect, building_node_path))
				continue
			var/obj/effect/building_node/node = effect
			node.on_construction(master)

	after_construction()

/datum/building_datum/proc/after_construction()
	return
