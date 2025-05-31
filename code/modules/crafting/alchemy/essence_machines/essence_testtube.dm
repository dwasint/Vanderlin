/obj/machinery/essence/test_tube
	name = "homonculus breeding tube"
	desc = "A large crystalline tank for creating gnome homoncului."
	icon = 'icons/roguetown/misc/splitter.dmi'
	icon_state = "essence_tank"
	density = TRUE
	anchored = TRUE
	var/datum/essence_storage/storage

	// Filter system
	var/list/allowed_essence_types = list(/datum/thaumaturgical_essence/life)

	var/gnome_progress = 0
	processing_priority = 1

/obj/machinery/essence/test_tube/Initialize()
	. = ..()
	storage = new /datum/essence_storage(src)
	storage.max_total_capacity = 1000
	storage.max_essence_types = 1

/obj/machinery/essence/test_tube/return_storage()
	return storage

/obj/machinery/essence/test_tube/process()
	if(!connection_processing || !output_connections.len)
		return
	var/list/prioritized_connections = sort_connections_by_priority(output_connections)
	for(var/datum/essence_connection/connection in prioritized_connections)
		if(!connection.active || !connection.target)
			continue
		var/datum/essence_storage/target_storage = get_target_storage(connection.target)
		if(!target_storage)
			continue
		var/essence_transferred = FALSE
		for(var/essence_type in storage.stored_essences)
			var/available = storage.get_essence_amount(essence_type)
			if(available > 0)
				if(!can_target_accept_essence(connection.target, essence_type))
					continue

				var/to_transfer = min(available, connection.transfer_rate)
				var/transferred = storage.transfer_to(target_storage, essence_type, to_transfer)
				if(transferred > 0)
					create_essence_transfer_effect(connection.target, essence_type, transferred)
					essence_transferred = TRUE
					break // Only transfer one type per cycle per connection

		if(essence_transferred)
			continue

/obj/machinery/essence/test_tube/update_icon()
	..()
	if(gnome_progress)
		overlays.Cut()
		var/image/gnome_overlay = image('icons/mob/gnome2.dmi', "gnome-tube")
		gnome_overlay.pixel_y = 6
		gnome_overlay.layer = layer - 0.1
		overlays += gnome_overlay
	else
		overlays.Cut()

/obj/machinery/essence/test_tube/is_essence_allowed(essence_type)
	return (essence_type in allowed_essence_types)

/obj/machinery/essence/test_tube/proc/can_accept_essence(essence_type)
	if(!is_essence_allowed(essence_type))
		return FALSE
	if(storage.get_available_space() <= 0)
		return FALSE
	if(!(essence_type in storage.stored_essences) && storage.stored_essences.len >= storage.max_essence_types)
		return FALSE

	return TRUE

/obj/machinery/essence/test_tube/attack_hand(mob/living/user)
	. = ..()
	if(!storage.has_essence(/datum/thaumaturgical_essence/life, 100))
		to_chat(user, span_warning("The tube requires at least 100 units of life essence to begin the process."))
		return
	if(gnome_progress)
		to_chat(user, span_notice("A gnome is already growing in the tube. Please wait..."))
		return

	to_chat(user, span_info("You activate the breeding process. The life essence begins to swirl and coalesce..."))

	gnome_progress = TRUE
	addtimer(CALLBACK(src, PROC_REF(create_gnome), user), 30 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(growth_sound_feedback)), 10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(growth_sound_feedback)), 20 SECONDS)
	update_icon()

/obj/machinery/essence/test_tube/proc/growth_sound_feedback()
	if(gnome_progress)
		visible_message(span_notice("The essence in [src] bubbles and shifts as the homunculus develops."))

/obj/machinery/essence/test_tube/proc/create_gnome(mob/living/user)
	if(!storage.has_essence(/datum/thaumaturgical_essence/life, 100))
		to_chat(user, span_warning("Insufficient life essence! The process fails..."))
		gnome_progress = FALSE
		update_icon()
		return

	storage.remove_essence(/datum/thaumaturgical_essence/life, 100)
	gnome_progress = FALSE
	update_icon()

	// Success sounds and effects
	visible_message(span_info("The crystalline tube glows brightly as the homunculus reaches maturity!"))

	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = new(get_turf(src))
	gnome.tamed(user)
	gnome.color = COLOR_PINK
	animate(gnome, color = COLOR_WHITE, time = 45 SECONDS)

	to_chat(user, span_boldnotice("Your gnome homunculus has been successfully created!"))

/obj/machinery/essence/test_tube/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/essence_vial))
		var/obj/item/essence_vial/vial = I

		if(!vial.contained_essence || vial.essence_amount <= 0)
			if(!length(storage.stored_essences))
				to_chat(user, span_warning("The test tube is empty."))
				return

			var/list/available_essences = list()
			for(var/essence_type in storage.stored_essences)
				var/datum/thaumaturgical_essence/essence = new essence_type
				available_essences["[essence.name] ([storage.stored_essences[essence_type]] units)"] = essence_type
				qdel(essence)

			var/choice = input(user, "Which essence would you like to extract?", "Extract Essence") in available_essences
			if(!choice)
				return

			var/essence_type = available_essences[choice]
			var/max_extract = min(storage.get_essence_amount(essence_type), vial.max_essence)
			var/amount_to_extract = input(user, "How much would you like to extract? (Max: [max_extract])", "Extract Amount", max_extract) as num

			if(amount_to_extract <= 0 || amount_to_extract > max_extract)
				return

			var/extracted = storage.remove_essence(essence_type, amount_to_extract)
			if(extracted > 0)
				vial.contained_essence = new essence_type
				vial.essence_amount = extracted
				vial.update_icon()
				to_chat(user, span_info("You extract [extracted] units of essence from the reservoir."))
			return

		var/essence_type = vial.contained_essence.type
		var/amount = vial.essence_amount

		if(!can_accept_essence(essence_type))
			to_chat(user, span_warning("The test tube cannot accept this essence."))
			return

		if(!storage.add_essence(essence_type, amount))
			to_chat(user, span_warning("The test tube cannot accept this essence."))
			return

		to_chat(user, span_info("You pour the [vial.contained_essence.name] into the reservoir."))

		vial.contained_essence = null
		vial.essence_amount = 0
		vial.update_icon()
		return TRUE

	..()

/obj/machinery/essence/test_tube/examine(mob/user)
	. = ..()
	. += span_notice("Capacity: [storage.get_total_stored()]/[storage.max_total_capacity] units")
	. += span_notice("Available space: [storage.get_available_space()] units")

	if(gnome_progress)
		. += span_boldnotice("A gnome homunculus is currently developing inside the tube.")

	if(storage.has_essence(/datum/thaumaturgical_essence/life, 100))
		. += span_info("The tube contains enough life essence to begin the breeding process.")
	else if(storage.has_essence(/datum/thaumaturgical_essence/life))
		. += span_warning("The tube needs at least 100 units of life essence to breed a homunculus.")

	if(storage.stored_essences.len > 0)
		. += span_notice("Stored essences:")
		for(var/essence_type in storage.stored_essences)
			var/datum/thaumaturgical_essence/essence = new essence_type
			. += span_notice("- [essence.name]: [storage.stored_essences[essence_type]] units")
			qdel(essence)
	else
		. += span_notice("The test tube is empty.")
