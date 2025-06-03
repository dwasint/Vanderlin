GLOBAL_DATUM_INIT(thaumic_research, /datum/thaumic_research_network, new())

/datum/thaumic_research_network
	var/list/unlocked_research = list()
	var/list/research_nodes = list()

/datum/thaumic_research_network/New()
	. = ..()
	// Initialize with basic research
	unlocked_research += /datum/thaumic_research_node/basic_understanding

	// Cache all research node types for easy access
	for(var/node_type in subtypesof(/datum/thaumic_research_node))
		var/datum/thaumic_research_node/node = new node_type
		research_nodes[node_type] = node

/datum/thaumic_research_network/proc/has_research(research_type)
	return research_type in unlocked_research

/datum/thaumic_research_network/proc/unlock_research(research_type)
	if(research_type in unlocked_research)
		return FALSE
	unlocked_research += research_type
	return TRUE

/datum/thaumic_research_network/proc/get_research_bonus(bonus_type)
	var/bonus = 1.0
	switch(bonus_type)
		if("splitting_efficiency")
			if(has_research(/datum/thaumic_research_node/basic_splitter))
				bonus += 0.20
			if(has_research(/datum/thaumic_research_node/advanced_splitter))
				bonus += 0.40
			if(has_research(/datum/thaumic_research_node/expert_splitter))
				bonus += 0.60
			if(has_research(/datum/thaumic_research_node/master_splitter))
				bonus += 1.80

	return bonus

/datum/thaumic_research_network/proc/get_cost_reduction(cost_type)
	var/reduction = 1.0
	switch(cost_type)
		if("life_essence_cost")
			if(has_research(/datum/thaumic_research_node/gnome_efficency))
				reduction -= 0.25
	return max(reduction, 0.1) // Never reduce below 10% of original cost

/datum/thaumic_research_network/proc/get_speed_multiplier(speed_type)
	var/multiplier = 1.0
	switch(speed_type)
		if("construct_creation")
			if(has_research(/datum/thaumic_research_node/gnome_speed))
				multiplier += 0.33
	return multiplier

/datum/thaumic_research_network/proc/can_use_machine(machine_type)
	switch(machine_type)
		if("test_tube")
			return has_research(/datum/thaumic_research_node/gnomes)
	return TRUE

/datum/thaumic_research_network/proc/get_available_research()
	var/list/available = list()
	for(var/node_type in subtypesof(/datum/thaumic_research_node))
		if(node_type in unlocked_research)
			continue
		var/datum/thaumic_research_node/node = research_nodes[node_type]
		if(!node)
			continue

		var/can_research = TRUE
		for(var/prereq in node.prerequisites)
			if(!(prereq in unlocked_research))
				can_research = FALSE
				break

		if(can_research)
			available += node_type

	return available

/datum/thaumic_research_network/proc/can_research(datum/thaumic_research_node/node_type)
	return(node_type in get_available_research())
