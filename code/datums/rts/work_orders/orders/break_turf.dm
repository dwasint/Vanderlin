/datum/work_order/break_turf
	name = "Break Turf"
	stamina_cost = 5
	work_time_left = 10 SECONDS
	visible_message = "starts to mine."

	var/datum/building_datum/on_failure_datum
	var/turf/breaking_turf

/datum/work_order/break_turf/New(mob/living/new_worker, datum/work_order/type, turf/turf_to_break, datum/building_datum/source_datum)
	. = ..()
	on_failure_datum = source_datum
	breaking_turf = turf_to_break
	set_movement_target(turf_to_break)

/datum/work_order/break_turf/finish_work()
	breaking_turf.turf_destruction("blunt")
	breaking_turf = null
	. = ..()

/datum/work_order/break_turf/stop_work()
	. = ..()
	if(on_failure_datum)
		on_failure_datum.needed_broken_turfs |= breaking_turf
