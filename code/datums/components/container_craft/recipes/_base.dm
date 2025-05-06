/datum/container_craft
	abstract_type = /datum/container_craft

	var/atom/output
	var/output_amount = 1

	var/user_craft = TRUE

	///if this is set we will only ever craft if only the contents are in the bag
	var/isolation_craft = FALSE

	var/list/requirements
	var/list/reagent_requirements
	///this needs a comment, basically if this is set we check for any of these in the path say /obj/item/sword, it will use /obj/item/sword/wooden
	var/list/wildcard_requirements

	//this is basically do we have any of these things in it on successful craft. Its up to the recipe to decide what to do with this information
	var/list/optional_requirements
	var/list/optional_wildcard_requirements
	var/list/optional_reagent_requirements

	var/crafting_time = 0

/datum/container_craft/proc/try_craft(obj/item/crafter, list/pathed_items, mob/initiator, datum/callback/on_craft_start, datum/callback/on_craft_failed)

	var/highest_multiplier = 0
	if(length(reagent_requirements))
		var/list/fake_reagents = reagent_requirements.Copy()
		for(var/datum/reagent/listed_reagent as anything in crafter.reagents.reagent_list) // this isn't perfect since it excludes blood reagent types like tiefling blood from recipes
			if(!(listed_reagent.type in fake_reagents))
				continue
			var/potential_multiplier = FLOOR(listed_reagent.volume / fake_reagents[listed_reagent.type], 1)
			if(!highest_multiplier)
				highest_multiplier = potential_multiplier
			else if(potential_multiplier < highest_multiplier)
				highest_multiplier = potential_multiplier
			if(potential_multiplier > 0)
				fake_reagents -= listed_reagent.type
		if(length(fake_reagents))
			return FALSE

	var/list/fake_requirements = requirements?.Copy()
	var/list/fake_wildcards = wildcard_requirements?.Copy()
	for(var/obj/item/path as anything in pathed_items)
		for(var/wildcard in fake_wildcards)
			if(!ispath(path, wildcard))
				continue
			var/potential_multiplier = FLOOR(pathed_items[path] / fake_wildcards[wildcard], 1)
			if(!highest_multiplier)
				highest_multiplier = potential_multiplier
			else if(potential_multiplier < highest_multiplier)
				highest_multiplier = potential_multiplier
			if(potential_multiplier > 0)
				fake_wildcards -= path
				pathed_items -= path
				continue
		if(path in fake_requirements)
			var/potential_multiplier = FLOOR(pathed_items[path] / fake_requirements[path], 1)
			if(!highest_multiplier)
				highest_multiplier = potential_multiplier
			else if(potential_multiplier < highest_multiplier)
				highest_multiplier = potential_multiplier
			if(potential_multiplier > 0)
				fake_requirements -= path
				pathed_items -= path
				continue


	if(length(fake_wildcards))
		return FALSE

	if(length(fake_requirements))
		return FALSE

	if(isolation_craft && length(pathed_items))
		return FALSE

	if(on_craft_start)
		on_craft_start.InvokeAsync(crafter, initiator)
	execute_craft(crafter, initiator, highest_multiplier, on_craft_failed)
	return TRUE

/datum/container_craft/proc/execute_craft(obj/item/crafter, mob/initiator, estimated_multiplier, datum/callback/on_craft_failed)

	if(user_craft)
		if(!do_after(initiator, get_real_time(crafter, initiator, estimated_multiplier), crafter))
			if(on_craft_failed)
				on_craft_failed.InvokeAsync(crafter, initiator)
			return
	else
		if(!do_atom(crafter, crafting_time * estimated_multiplier, crafter))
			if(on_craft_failed)
				on_craft_failed.InvokeAsync(crafter, initiator)
			return

	for(var/i = 1 to estimated_multiplier)
		// First validate that all requirements are still present
		var/list/stored_items = list()
		for(var/obj/item/item in crafter.contents)
			stored_items |= item.type
			stored_items[item.type]++

		// Track which items to remove, indexed by type
		var/list/items_to_remove = list()
		// Track which actual item objects we'll remove
		var/list/obj/item/items_to_delete = list()

		// Track all the data about what was used in crafting
		var/list/passed_reagents = list()
		var/list/passed_wildcards = list()
		var/list/passed_requirements = list()
		var/list/found_optional_requirements = list()
		var/list/found_optional_wildcards = list()
		var/list/found_optional_reagents = list()

		// Check reagent requirements
		if(length(reagent_requirements))
			for(var/reagent as anything in reagent_requirements)
				if(!crafter.reagents.has_reagent(reagent, reagent_requirements[reagent]))
					return FALSE
				passed_reagents |= reagent
				passed_reagents[reagent] = reagent_requirements[reagent]

		// Check item requirements
		if(length(requirements))
			for(var/item_type in requirements)
				if(stored_items[item_type] < requirements[item_type])
					return FALSE
				passed_requirements |= item_type
				passed_requirements[item_type] = requirements[item_type]
				items_to_remove[item_type] = requirements[item_type]

		// Check wildcard requirements
		if(length(wildcard_requirements))
			var/list/wildcarded_types = list()
			for(var/wildcard in wildcard_requirements)
				var/items_found = 0
				var/amount_needed = wildcard_requirements[wildcard]

				for(var/obj/item/candidate_item in crafter.contents)
					if(ispath(candidate_item.type, wildcard) && !(candidate_item in items_to_delete))
						if(!wildcarded_types[candidate_item.type])
							wildcarded_types[candidate_item.type] = 0

						var/can_take = min(amount_needed - items_found, 1) // Take one at a time
						items_found += can_take
						wildcarded_types[candidate_item.type] += can_take

						if(can_take > 0)
							items_to_delete += candidate_item

						if(items_found >= amount_needed)
							break

				if(items_found < amount_needed)
					return FALSE

				passed_wildcards[wildcard] = wildcarded_types

		// Check optional requirements
		if(length(optional_requirements))
			for(var/opt_req in optional_requirements)
				if(stored_items[opt_req] >= optional_requirements[opt_req])
					found_optional_requirements |= opt_req
					found_optional_requirements[opt_req] = optional_requirements[opt_req]

					if(!items_to_remove[opt_req])
						items_to_remove[opt_req] = 0
					items_to_remove[opt_req] += optional_requirements[opt_req]

		// Check optional wildcards
		if(length(optional_wildcard_requirements))
			for(var/opt_wildcard in optional_wildcard_requirements)
				var/found = FALSE
				for(var/obj/item/candidate_item in crafter.contents)
					if(ispath(candidate_item.type, opt_wildcard) && !(candidate_item in items_to_delete))
						found_optional_wildcards[opt_wildcard] = candidate_item.type
						items_to_delete += candidate_item
						found = TRUE
						break

				if(found)
					found_optional_wildcards |= opt_wildcard

		// Check optional reagents
		if(length(optional_reagent_requirements))
			for(var/opt_reagent in optional_reagent_requirements)
				if(crafter.reagents.has_reagent(opt_reagent, optional_reagent_requirements[opt_reagent]))
					found_optional_reagents |= opt_reagent
					found_optional_reagents[opt_reagent] = optional_reagent_requirements[opt_reagent]

		// Now that we've verified everything, execute the removals

		// Remove reagents first
		for(var/reagent in passed_reagents)
			crafter.reagents.remove_reagent(reagent, passed_reagents[reagent])

		for(var/opt_reagent in found_optional_reagents)
			crafter.reagents.remove_reagent(opt_reagent, found_optional_reagents[opt_reagent])

		// Remove items by type
		for(var/item_type in items_to_remove)
			var/amount_to_remove = items_to_remove[item_type]
			for(var/obj/item/candidate_item in crafter.contents)
				if(amount_to_remove <= 0)
					break
				if(candidate_item.type == item_type && !(candidate_item in items_to_delete))
					items_to_delete += candidate_item
					amount_to_remove--

		// Remove all tracked items
		for(var/obj/item/item_to_delete in items_to_delete)
			SEND_SIGNAL(crafter, COMSIG_TRY_STORAGE_TAKE, item_to_delete, get_turf(crafter))
			qdel(item_to_delete)

		create_item(crafter, initiator, found_optional_requirements, found_optional_wildcards, found_optional_reagents)

/datum/container_craft/proc/create_item(obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents)
	for(var/j = 1 to output_amount)
		var/atom/created_output = new output(get_turf(crafter))
		SEND_SIGNAL(crafter, COMSIG_TRY_STORAGE_INSERT, created_output, null, null, TRUE, TRUE)
		after_craft(created_output, crafter, initiator, found_optional_requirements, found_optional_wildcards, found_optional_reagents)


/datum/container_craft/proc/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents)
	// This is an extension point for specific crafting types to do additional processing
	// basically used exclusively for optional requirements
	return

/datum/container_craft/proc/get_real_time(atom/host, mob/user, estimated_multiplier)
	return crafting_time * estimated_multiplier
