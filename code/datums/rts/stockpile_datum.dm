/datum/stockpile
	var/list/stored_materials = list(
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

/datum/stockpile/proc/has_resources(list/resources_to_spend)
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			return FALSE
		if(stored_materials[resource] < resources_to_spend[resource])
			return FALSE
	return TRUE

/datum/stockpile/proc/add_resources(list/resources_to_spend)
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			continue
		stored_materials[resource] += resources_to_spend[resource]
	return TRUE

/datum/stockpile/proc/remove_resources(list/resources_to_spend)
	for(var/resource in resources_to_spend)
		if(!(resource in stored_materials))
			continue
		stored_materials[resource] -= resources_to_spend[resource]
	return TRUE
