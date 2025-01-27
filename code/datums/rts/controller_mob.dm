/mob/camera/strategy_controller
	name = "Strategy Controller"
	real_name = "Strategy Controller"
	desc = "The overmind. It controls the kobolds."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "yalp_elor"
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	plane = GAME_PLANE_UPPER
	see_invisible = SEE_INVISIBLE_LIVING
	uses_intents = FALSE
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	pass_flags = PASSCLOSEDTURF | PASSMOB | PASSTABLE

	var/list/worker_mobs = list()
	var/list/dead_workers = list()

	var/datum/stockpile/resource_stockpile
	var/datum/stockpile_requests/requests

	var/list/possible_job_actions = list()

	var/list/in_progress_workorders = list()
	var/list/building_requests = list()

	var/list/constructed_building_nodes = list()

	var/atom/movable/screen/controller_ui/controller_ui/displayed_mob_ui

/mob/camera/strategy_controller/Initialize()
	. = ..()
	START_PROCESSING(SSstrategy_master, src)

/mob/camera/strategy_controller/proc/add_assignments(list/assignments)
	possible_job_actions |= assignments

/mob/camera/strategy_controller/proc/add_new_worker(mob/living/worker)
	worker_mobs |= worker

/mob/camera/strategy_controller/proc/test_place_stockpile()
	queue_building_build(/datum/building_datum/stockpile, get_turf(src))

/mob/camera/strategy_controller/proc/create_testing_controlled_mob()
	var/turf/new_turf = get_turf(src)
	var/mob/living/simple_animal/hostile/retaliate/rogue/bigrat/new_rat = new(new_turf)
	new_rat.controller_mind = new(new_rat, src)

/mob/camera/strategy_controller/proc/queue_building_build(datum/building_datum/building, turf/source_turf)
	new building(src, source_turf)

/mob/camera/strategy_controller/RightClickOn(atom/A, params)
	if(isliving(A))
		var/mob/living/living = A
		if(living.controller_mind)
			if(displayed_mob_ui)
				displayed_mob_ui.remove_ui(client)
			displayed_mob_ui  = living.controller_mind.stats
			displayed_mob_ui.add_ui(client)

	if(isclosedturf(A))
		var/datum/queued_workorder/new_queued = new /datum/queued_workorder(/datum/work_order/break_turf, A)
		in_progress_workorders += new_queued
	. = ..()

/mob/camera/strategy_controller/process()
	if(length(building_requests))
		for(var/mob/living/mob in worker_mobs)
			if(!length(building_requests))
				return
			if(mob.controller_mind.current_task)
				continue

			for(var/datum/building_datum/building in building_requests)
				if(building.try_work_on(mob))
					return

	if(length(in_progress_workorders))
		for(var/mob/living/mob in worker_mobs)
			if(!length(in_progress_workorders))
				return
			if(mob.controller_mind.current_task)
				continue

			for(var/datum/queued_workorder/workorder in in_progress_workorders)
				if(workorder.arg_1)
					if(!length(get_path_to(mob, workorder.arg_1, /turf/proc/Distance, 32 + 1, 250,1)))
						continue
				mob.controller_mind.set_current_task(workorder.work_path, workorder.arg_1, workorder.arg_2, workorder.arg_3, workorder.arg_4)
				in_progress_workorders -= workorder
				qdel(workorder)
				return

/mob/camera/Login()
	. = ..()
	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

/mob/camera/auto_deadmin_on_login()
	return

/mob/camera/Logout()
	update_z(null)
	return ..()

/mob/camera/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)

/mob/camera/proc/update_z(new_z) // 1+ to register, null to unregister
	if (registered_z != new_z)
		if (registered_z)
			SSmobs.camera_players_by_zlevel[registered_z] -= src
		if (client)
			if (new_z)
				SSmobs.camera_players_by_zlevel[new_z] += src
			registered_z = new_z
		else
			registered_z = null
