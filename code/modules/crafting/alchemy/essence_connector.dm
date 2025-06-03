/obj/item/essence_connector
	name = "thaumic connector"
	desc = "A mystical linking device used to create essence flow connections between alchemical apparatus. Click and drag between devices to establish connections."
	icon = 'icons/roguetown/misc/alchemy.dmi'
	icon_state = "connector"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/machinery/source_device = null
	var/connecting = FALSE

/obj/item/essence_connector/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return

	if(!istype(target, /obj/machinery))
		return

	var/obj/machinery/machine = target
	if(!is_essence_device(machine))
		to_chat(user, span_warning("[machine] is not compatible with essence connections."))
		return

	if(!connecting)
		// Start connection
		source_device = machine
		connecting = TRUE
		to_chat(user, span_info("Connection started from [machine.name]. Click on another device to complete the link."))
		return

	// Complete connection
	if(machine == source_device)
		to_chat(user, span_warning("Cannot connect a device to itself."))
		return

	if(create_connection(source_device, machine, user))
		to_chat(user, span_info("Successfully connected [source_device.name] to [machine.name]."))
	else
		to_chat(user, span_warning("Cannot establish connection between these devices."))

	// Reset
	source_device = null
	connecting = FALSE

/obj/item/essence_connector/proc/is_essence_device(obj/machinery/M)
	return istype(M, /obj/machinery/essence)

/obj/item/essence_connector/proc/create_connection(obj/machinery/source, obj/machinery/target, mob/user)
	// Check if connection is valid
	if(!can_connect(source, target))
		return FALSE

	// Create the connection datum
	var/datum/essence_connection/connection = new()
	connection.source = source
	connection.target = target
	connection.established_by = user.ckey

	source.Beam(target, "light_beam", time = 0.5 SECONDS)

	// Add to source's output connections
	if(!source.vars["output_connections"])
		source.vars["output_connections"] = list()
	source.vars["output_connections"] += connection

	// Add to target's input connections
	if(!target.vars["input_connections"])
		target.vars["input_connections"] = list()
	target.vars["input_connections"] += connection

	// Start processing if not already
	if(!source.vars["connection_processing"])
		source.vars["connection_processing"] = TRUE
		START_PROCESSING(SSobj, source)

	return TRUE

/obj/item/essence_connector/proc/can_connect(obj/machinery/source, obj/machinery/target)
	// Splitter can output to combiner or reservoir
	if(istype(source, /obj/machinery/essence/splitter))
		return istype(target, /obj/machinery/essence/combiner) || istype(target, /obj/machinery/essence/reservoir) || istype(target, /obj/machinery/essence/enchantment_altar) || istype(target, /obj/machinery/essence/test_tube) || istype(target, /obj/machinery/essence/infuser) || istype(target, /obj/machinery/essence/research_matrix)

	// Combiner can output to reservoir
	if(istype(source, /obj/machinery/essence/combiner))
		return istype(target, /obj/machinery/essence/reservoir) || istype(target, /obj/machinery/essence/enchantment_altar) || istype(target, /obj/machinery/essence/test_tube) || istype(target, /obj/machinery/essence/infuser) || istype(target, /obj/machinery/essence/research_matrix)

	// Reservoir can output to combiner
	if(istype(source, /obj/machinery/essence/reservoir))
		return istype(target, /obj/machinery/essence/combiner) || istype(target, /obj/machinery/essence/reservoir) || istype(target, /obj/machinery/essence/enchantment_altar) || istype(target, /obj/machinery/essence/test_tube) || istype(target, /obj/machinery/essence/infuser) || istype(target, /obj/machinery/essence/research_matrix)

	if(istype(source, /obj/machinery/essence/harvester))
		return istype(target, /obj/machinery/essence/combiner) || istype(target, /obj/machinery/essence/reservoir) || istype(target, /obj/machinery/essence/enchantment_altar) || istype(target, /obj/machinery/essence/test_tube) || istype(target, /obj/machinery/essence/infuser) || istype(target, /obj/machinery/essence/research_matrix)

	return FALSE

// Connection datum to track relationships
/datum/essence_connection
	var/obj/machinery/source
	var/obj/machinery/target
	var/transfer_rate = 10 // units per process cycle
	var/active = TRUE
	var/established_by

/obj/effect/essence_orb
	name = "essence orb"
	desc = "A concentrated ball of thaumaturgical essence traveling between devices."
	icon = 'icons/effects/effects.dmi'
	icon_state = "phasein"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	var/essence_color = "#4A90E2"
	var/obj/machinery/destination
	var/travel_time = 2 SECONDS

/obj/effect/essence_orb/Initialize(mapload, dest_machine, essence_type, travel_duration = 2 SECONDS)
	. = ..()
	destination = dest_machine
	travel_time = travel_duration

	if(essence_type)
		var/datum/thaumaturgical_essence/essence = new essence_type
		essence_color = essence.color
		qdel(essence)

	color = essence_color
	var/mutable_appearance/glow = mutable_appearance(icon, icon_state)
	glow.color = essence_color
	glow.plane = EMISSIVE_PLANE
	overlays += glow

	// Start the journey
	animate_to_destination()

/obj/effect/essence_orb/proc/animate_to_destination()
	if(!destination)
		qdel(src)
		return

	var/turf/start_turf = get_turf(src)
	var/turf/end_turf = get_turf(destination)

	if(!start_turf || !end_turf)
		qdel(src)
		return

	var/dx = end_turf.x - start_turf.x
	var/dy = end_turf.y - start_turf.y
	var/distance = sqrt(dx*dx + dy*dy)

	var/mid_x = start_turf.x + (dx * 0.5) + round(rand(-1,1) * min(distance * 0.3, 2))
	var/mid_y = start_turf.y + (dy * 0.5) + round(rand(-1,1) * min(distance * 0.3, 2))

	var/half_time = travel_time * 0.5

	animate(src, pixel_x = (mid_x - start_turf.x) * 32, pixel_y = (mid_y - start_turf.y) * 32 + 8,
			time = half_time, easing = SINE_EASING)
	animate(pixel_x = (end_turf.x - start_turf.x) * 32, pixel_y = (end_turf.y - start_turf.y) * 32,
			time = half_time, easing = SINE_EASING)
	animate(transform = matrix().Scale(1.2, 1.2), time = travel_time * 0.25, loop = 4,
			easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(), time = travel_time * 0.25, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(arrive_at_destination)), travel_time + 0.2 SECONDS)

/obj/effect/essence_orb/proc/arrive_at_destination()
	if(destination)
		var/turf/dest_turf = get_turf(destination)
		if(dest_turf)
			var/obj/effect/temp_visual/sparkles = new(dest_turf)
			sparkles.color = essence_color
			sparkles.icon_state = "essence_sparkle"
			sparkles.layer = ABOVE_MOB_LAYER
			destination.flick_overlay_view(image('icons/effects/effects.dmi', destination, "essence_receive", ABOVE_MOB_LAYER), 0.5 SECONDS)

	qdel(src)
