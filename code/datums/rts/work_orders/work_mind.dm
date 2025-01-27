/mob/living
	var/datum/worker_mind/controller_mind

/mob/living/proc/made_into_controller_mob()
	QDEL_NULL(ai_controller)

/mob/living/simple_animal/hostile/made_into_controller_mob()
	. = ..()
	AIStatus = AI_OFF
	can_have_ai = FALSE

/datum/worker_mind
	var/mob/camera/strategy_controller/master
	var/mob/living/worker
	///10 is default so 20 is double etc
	var/work_speed = 10
	///our worker walk speed
	var/walkspeed = 5
	///100 is default
	var/maximum_stamina = 100
	var/current_stamina = 100

	var/datum/work_order/current_task
	var/turf/movement_target

	var/list/worker_gear
	var/list/worker_moodlets

	var/datum/idle_tendancies/idle

	var/paused = FALSE

	var/atom/movable/screen/controller_ui/controller_ui/stats

/datum/worker_mind/New(mob/living/new_worker, mob/camera/strategy_controller/new_master)
	. = ..()
	idle = new /datum/idle_tendancies/basic
	master = new_master
	worker = new_worker

	worker.pass_flags |= PASSMOB
	worker.density = FALSE

	worker.real_name = "[pick( world.file2list("strings/rt/names/dwarf/dwarmm.txt") )] the [worker.real_name]"
	worker.name = worker.real_name

	master.add_new_worker(worker)
	worker.made_into_controller_mob()
	stats = new /atom/movable/screen/controller_ui/controller_ui(worker, src)
	START_PROCESSING(SSstrategy_master, src)

/datum/worker_mind/proc/head_to_target()
	walk_to(worker, movement_target, 1, walkspeed)

/datum/worker_mind/proc/start_task()
	current_task.start_working(worker)

/datum/worker_mind/process()
	if(paused)
		return
	if(current_stamina <= 0)
		try_restore_stamina()
		return
	if(movement_target && (!worker.CanReach(movement_target)))
		head_to_target()
		return
	if(current_task)
		start_task()
		return
	if(length(master.in_progress_workorders))
		return
	if(length(master.building_requests))
		return
	start_idle()

/datum/worker_mind/proc/start_idle()
	idle.perform_idle(master, worker)

/datum/worker_mind/proc/try_restore_stamina()
	if(!length(master.constructed_building_nodes))
		var/list/turfs = view(6, worker)
		shuffle_inplace(turfs)
		for(var/turf/open/open in turfs)
			set_current_task(/datum/work_order/nappy_time, open)
			break
	else
		for(var/obj/effect/building_node/node in master.constructed_building_nodes)
			if(!istype(node, /obj/effect/building_node/kitchen))
				continue
			set_current_task(/datum/work_order/go_try_eat, node)
			return

		var/list/turfs = view(6, worker)
		shuffle_inplace(turfs)
		for(var/turf/open/open in turfs)
			set_current_task(/datum/work_order/nappy_time, open)
			break

/datum/worker_mind/proc/set_current_task(datum/work_order/order, ...)
	var/list/arg_list = list(worker) + args
	current_task = new order(arglist(arg_list))

/datum/worker_mind/proc/finish_work(success, stamina_cost)
	current_stamina = max(0, current_stamina - stamina_cost)
	current_task = null
	movement_target = null
	paused = FALSE
	walk(worker, 0)

/datum/worker_mind/proc/stop_working()
	current_task = null
	movement_target = null
	paused = FALSE
	walk(worker, 0)

/datum/worker_mind/proc/set_movement_target(atom/target)
	walk(worker, 0)
	movement_target = target

/datum/worker_mind/proc/add_gear(obj/item/gear)
	LAZYADD(worker_gear, gear)
	gear.forceMove(worker)

/datum/worker_mind/proc/remove_gear(obj/item/gear)
	LAZYREMOVE(worker_gear, gear)
	gear.forceMove(get_turf(worker))

/datum/worker_mind/proc/add_test_instrument()
	var/obj/item/rogue/instrument/guitar/guitar = new(get_turf(worker))
	add_gear(guitar)

/datum/worker_mind/proc/play_testing_song()
	if(current_task)
		current_task.stop_work()

	for(var/obj/item/gear in worker_gear)
		if(!istype(gear, /obj/item/rogue/instrument))
			continue

		var/list/turfs = view(6, worker)
		shuffle_inplace(turfs)
		for(var/turf/open/open in turfs)
			set_current_task(/datum/work_order/play_music, open, gear)
			break

/datum/worker_mind/proc/update_stat_panel()
	stats.update_text()
