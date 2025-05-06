/datum/container_craft
	abstract_type = /datum/container_craft

	var/atom/output
	var/output_amount = 1

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

	var/list/contents = crafter.contents.Copy() //this is a copy because we remove from the list as it happens

	var/highest_multiplier = 0
	if(length(reagent_requirements))
		var/list/fake_reagents = reagent_requirements.Copy()
		for(var/datum/reagent/listed_reagent as anything in crafter.reagents.reagent_list) // this isn't perfect since it excludes blood reagent types like tiefling blood from recipes
			if(!listed_reagent.type in fake_reagents)
				continue
			var/potential_multiplier = FLOOR(listed_reagent.volume / fake_reagents[listed_reagent.type])
			if(!highest_multiplier)
				highest_multiplier = potential_multiplier
			else if(potential_multiplier < highest_multiplier)
				highest_multipler = potential_multiplier
			if(potential_multiplier > 0)
				fake_reagents -= listed_reagent.type
		if(length(fake_reagents))
			return FALSE

	var/list/fake_requirements = requirements.Copy()
	var/list/fake_wildcards = wildcard_requirements.Copy()
	for(var/obj/item/path as anything in pathed_items)
		for(var/wildcard in fake_wildcards)
			if(!ispath(path, wildcard))
				continue
			var/potential_multiplier = FLOOR(pathed_items[path] / fake_wildcards[wildcard])
			if(!highest_multiplier)
				highest_multiplier = potential_multiplier
			else if(potential_multiplier < highest_multiplier)
				highest_multipler = potential_multiplier
			if(potential_multiplier > 0)
				fake_wildcards -= path
				pathed_items -= path
				continue
		if(path in fake_requirements)
			var/potential_multiplier = FLOOR(pathed_items[path] / fake_requirements[path])
			if(!highest_multiplier)
				highest_multiplier = potential_multiplier
			else if(potential_multiplier < highest_multiplier)
				highest_multipler = potential_multiplier
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

/datum/container_craft/proc/execute_craft(obj/item/crafter, mob/initator, estimated_multiplier, datum/callback/on_craft_failed)

	if(!do_after(crafter, crafting_time * estimated_multiplier, crafter))
		if(on_craft_failed)
			on_craft_failed.InvokeAsync(crafter, initiator)
		return

	var/list/fake_requirements = requirements.Copy()
	var/list/fake_wildcards = wildcard_requirements.Copy()
	var/list/fake_reagents = reagent_requirements.Copy()

	for(var/i = 1 to estimated_multiplier)
		var/list/stored_items = list()
		for(var/obj/item/item in host.contents)
			stored_items |= item.type
			stored_items[item.type]++

		var/list/passed_reagents = list()
		var/list/passed_wildcards = list()
		var/list/passed_requirements = list()

		for(var/reagent as anything in fake_reagents)
			if(!crafter.reagents.has_reagent(reagent, fake_reagents[reagent]))
				return FALSE
			passed_reagents |= reagent

		for(var/item in fake_requirements)
			if(fake_requirements[item] > stored_items[item])
				return FALSE
			passed_requirements |= item
			passed_requirements[item] = fake_requirements[item]

		var/list/wildcarded_types = list()
		for(var/wildcard in fake_wildcards)
			for(var/path in stored_items)
				if(!ispath(path, wildcard))
					return FALSE


