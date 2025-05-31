/obj/machinery/essence
	plane = GAME_PLANE_UPPER
	layer = ABOVE_MOB_LAYER

	var/processing = FALSE
	var/datum/essence_storage/input_storage
	var/datum/essence_storage/output_storage
	var/list/output_connections = list()
	var/list/input_connections = list()
	var/connection_processing = FALSE

	var/processing_priority

/obj/machinery/essence/proc/is_essence_allowed(essence_type)
	return TRUE

/obj/machinery/essence/proc/can_target_accept_essence(obj/machinery/essence/target, essence_type)
	return target.is_essence_allowed(essence_type)

/obj/machinery/essence/proc/create_essence_transfer_effect(obj/machinery/target, essence_type, amount)
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return

	var/turf/target_turf = get_turf(target)
	var/distance = get_dist(source_turf, target_turf)
	var/travel_time = max(1 SECONDS, min(3 SECONDS, distance * 0.3 SECONDS))

	new /obj/effect/essence_orb(source_turf, target, essence_type, travel_time)

	//playsound(src, 'sound/misc/essence_transfer.ogg', 25, TRUE)

/obj/machinery/essence/proc/get_target_storage(obj/machinery/essence/target)
	if(!istype(target))
		return null
	return target?.return_storage()

/obj/machinery/essence/proc/return_storage()
	return input_storage

/obj/machinery/essence/proc/sort_connections_by_priority(list/connections)
	var/list/prioritized = list()
	var/list/reservoirs = list()
	var/list/splitters = list()
	var/list/combiners = list()
	var/list/others = list()

	for(var/datum/essence_connection/connection in connections)
		if(!connection.target)
			continue

		if(istype(connection.target, /obj/machinery/essence/reservoir))
			reservoirs += connection
		else if(istype(connection.target, /obj/machinery/essence/splitter))
			splitters += connection
		else if(istype(connection.target, /obj/machinery/essence/combiner))
			combiners += connection
		else
			others += connection

	prioritized += reservoirs
	prioritized += splitters
	prioritized += combiners
	prioritized += others

	return prioritized
