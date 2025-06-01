/obj/machinery/essence/reservoir
	name = "essence reservoir"
	desc = "A large crystalline tank for storing massive quantities of thaumaturgical essences."
	icon = 'icons/roguetown/misc/splitter.dmi'
	icon_state = "essence_tank"
	density = TRUE
	anchored = TRUE
	var/datum/essence_storage/storage

	var/list/allowed_essence_types = list() // Empty list = allow all types
	var/filter_mode = FALSE // FALSE = allow all, TRUE = whitelist mode

	processing_priority = 1

/obj/machinery/essence/reservoir/Initialize()
	. = ..()
	storage = new /datum/essence_storage(src)
	storage.max_total_capacity = 1000
	storage.max_essence_types = 25

/obj/machinery/essence/reservoir/return_storage()
	return storage

/obj/machinery/essence/reservoir/process()
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


/obj/machinery/essence/reservoir/is_essence_allowed(essence_type)
	if(!filter_mode)
		return TRUE // No filtering active

	if(!length(allowed_essence_types))
		return TRUE // Empty whitelist = accept all

	return (essence_type in allowed_essence_types)

/obj/machinery/essence/reservoir/proc/can_accept_essence(essence_type)
	if(!is_essence_allowed(essence_type))
		return FALSE

	if(storage.get_available_space() <= 0)
		return FALSE

	if(!(essence_type in storage.stored_essences) && storage.stored_essences.len >= storage.max_essence_types)
		return FALSE

	return TRUE

/obj/machinery/essence/reservoir/proc/toggle_filter_mode(mob/user)
	filter_mode = !filter_mode
	if(filter_mode)
		to_chat(user, span_info("Filter mode enabled. Only allowed essence types will be accepted."))
	else
		to_chat(user, span_info("Filter mode disabled. All essence types will be accepted."))

/obj/machinery/essence/reservoir/proc/add_essence_filter(essence_type, mob/user)
	if(essence_type in allowed_essence_types)
		to_chat(user, span_warning("This essence type is already in the filter list."))
		return FALSE

	allowed_essence_types += essence_type
	var/datum/thaumaturgical_essence/essence = new essence_type
	to_chat(user, span_info("[essence.name] added to allowed essence types."))
	qdel(essence)
	return TRUE

/obj/machinery/essence/reservoir/proc/remove_essence_filter(essence_type, mob/user)
	if(!(essence_type in allowed_essence_types))
		to_chat(user, span_warning("This essence type is not in the filter list."))
		return FALSE

	allowed_essence_types -= essence_type
	var/datum/thaumaturgical_essence/essence = new essence_type
	to_chat(user, span_info("[essence.name] removed from allowed essence types."))
	qdel(essence)
	return TRUE

/obj/machinery/essence/reservoir/proc/show_filter_menu(mob/user)
	var/list/options = list()
	options["Toggle Filter Mode ([filter_mode ? "ON" : "OFF"])"] = "toggle"
	options["Add Essence Type to Filter"] = "add"

	if(allowed_essence_types.len > 0)
		options["Remove Essence Type from Filter"] = "remove"
		options["Clear All Filters"] = "clear"

	options["View Current Filters"] = "view"
	options["Cancel"] = "cancel"

	var/choice = input(user, "Essence Filter Configuration", "Filter Menu") in options
	if(!choice || choice == "cancel")
		return

	switch(options[choice])
		if("toggle")
			toggle_filter_mode(user)

		if("add")
			var/list/available_types = list()
			for(var/essence_type in storage.stored_essences)
				var/datum/thaumaturgical_essence/essence = new essence_type
				available_types["[essence.name]"] = essence_type
				qdel(essence)
			var/list/common_essences = list(
				/datum/thaumaturgical_essence/fire,
				/datum/thaumaturgical_essence/water,
				/datum/thaumaturgical_essence/earth,
				/datum/thaumaturgical_essence/air,
				/datum/thaumaturgical_essence/life,
			)

			for(var/essence_type in common_essences)
				var/datum/thaumaturgical_essence/essence = new essence_type
				if(!(essence.name in available_types))
					available_types["[essence.name]"] = essence_type
				qdel(essence)

			if(!length(available_types))
				to_chat(user, span_warning("No essence types available to add to filter."))
				return

			var/selected = input(user, "Select essence type to add to filter:", "Add Filter") in available_types
			if(selected)
				add_essence_filter(available_types[selected], user)

		if("remove")
			var/list/filter_options = list()
			for(var/essence_type in allowed_essence_types)
				var/datum/thaumaturgical_essence/essence = new essence_type
				filter_options["[essence.name]"] = essence_type
				qdel(essence)

			var/selected = input(user, "Select essence type to remove from filter:", "Remove Filter") in filter_options
			if(selected)
				remove_essence_filter(filter_options[selected], user)

		if("clear")
			allowed_essence_types.Cut()
			to_chat(user, span_info("All essence filters cleared."))

		if("view")
			if(!length(allowed_essence_types))
				to_chat(user, span_info("No essence filters configured."))
			else
				to_chat(user, span_info("Allowed essence types:"))
				for(var/essence_type in allowed_essence_types)
					var/datum/thaumaturgical_essence/essence = new essence_type
					to_chat(user, span_info("- [essence.name]"))
					qdel(essence)

/obj/machinery/essence/reservoir/attackby(obj/item/I, mob/user, params)
    if(istype(I, /obj/item/essence_vial))
        var/obj/item/essence_vial/vial = I
        if(!vial.contained_essence || vial.essence_amount <= 0)
            if(!length(storage.stored_essences))
                to_chat(user, span_warning("The reservoir is empty."))
                return
            // Create radial menu for essence selection
            var/list/radial_options = list()
            var/list/essence_mapping = list()
            for(var/essence_type in storage.stored_essences)
                var/datum/thaumaturgical_essence/essence = new essence_type
                var/display_name
                if(HAS_TRAIT(user, TRAIT_LEGENDARY_ALCHEMIST))
                    display_name = essence.name
                else
                    display_name = "Essence smelling of [essence.smells_like]"
                var/option_key = "[display_name] ([storage.stored_essences[essence_type]] units)"
                var/datum/radial_menu_choice/choice = new()
                var/image/image = image(icon = 'icons/roguetown/misc/alchemy.dmi', icon_state = "essence")
                image.color = essence.color
                choice.image = image
                choice.name = display_name
                if(HAS_TRAIT(user, TRAIT_LEGENDARY_ALCHEMIST))
                    choice.info = "Extract [essence.name] essence. Smells of [essence.smells_like]."
                else
                    choice.info = "Extract unknown essence. Smells of [essence.smells_like]."
                radial_options[option_key] = choice
                essence_mapping[option_key] = essence_type
                qdel(essence)
            var/choice = show_radial_menu(user, src, radial_options, custom_check = CALLBACK(src, PROC_REF(check_menu_validity), user, vial))
            if(!choice || !essence_mapping[choice])
                return
            var/essence_type = essence_mapping[choice]
            var/max_extract = min(storage.get_essence_amount(essence_type), vial.max_essence)
            var/amount_to_extract = min(max_extract, vial.extract_amount)
            if(amount_to_extract <= 0)
                to_chat(user, span_warning("Cannot extract any essence with current vial settings."))
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
            if(filter_mode)
                to_chat(user, span_warning("This reservoir's filter does not allow [vial.contained_essence.name]."))
            else
                to_chat(user, span_warning("The reservoir cannot accept this essence (capacity or type limit reached)."))
            return
        if(!storage.add_essence(essence_type, amount))
            to_chat(user, span_warning("The reservoir cannot accept this essence (capacity or type limit reached)."))
            return
        to_chat(user, span_info("You pour the [vial.contained_essence.name] into the reservoir."))
        vial.contained_essence = null
        vial.essence_amount = 0
        vial.update_icon()
        return TRUE
    ..()

/obj/machinery/essence/reservoir/attack_hand(mob/living/user)
	. = ..()
	show_filter_menu(user)

/obj/machinery/essence/reservoir/examine(mob/user)
	. = ..()
	. += span_notice("Capacity: [storage.get_total_stored()]/[storage.max_total_capacity] units")
	. += span_notice("Available space: [storage.get_available_space()] units")

	if(filter_mode)
		. += span_notice("Filter Mode: ACTIVE")
		if(allowed_essence_types.len > 0)
			. += span_notice("Allowed essence types: [allowed_essence_types.len]")
		else
			. += span_notice("Filter list is empty (accepting all types)")
	else
		. += span_notice("Filter Mode: DISABLED")

	if(storage.stored_essences.len > 0)
		. += span_notice("Stored essences:")
		for(var/essence_type in storage.stored_essences)
			var/datum/thaumaturgical_essence/essence = new essence_type
			if(HAS_TRAIT(user, TRAIT_LEGENDARY_ALCHEMIST))
				. += span_notice("Contains [storage.stored_essences[essence_type]] units of [essence.name].")
			else
				. += span_notice("Contains [storage.stored_essences[essence_type]] units of essence smelling of [essence.smells_like].")
			qdel(essence)
	else
		. += span_notice("The reservoir is empty.")

/obj/machinery/essence/reservoir/filled
	var/list/essence_list = list()

/obj/machinery/essence/reservoir/filled/Initialize()
	. = ..()
	for(var/datum/thaumaturgical_essence/essence as anything in essence_list)
		storage.add_essence(essence, essence_list[essence])

/obj/machinery/essence/reservoir/filled/life
	essence_list = list(/datum/thaumaturgical_essence/life = 1000)
