/datum/chimeric_table
	/// Blood types that work normally with this node (list of /datum/blood_type paths)
	var/list/compatible_blood_types = list()
	/// Blood types that are rejected by this node (list of /datum/blood_type paths)
	var/list/incompatible_blood_types = list()
	/// Blood types that work exceptionally well (list of /datum/blood_type paths)
	var/list/preferred_blood_types = list()
	var/base_blood_cost = 0.3
	var/preferred_blood_bonus = 0.5
	var/incompatible_blood_penalty = 2.0
	var/node_tier = 1
	var/node_purity_min = 30
	var/node_purity_max = 70

	// Weighted lists for each node slot type - if no length just picks randomly using assigned weights
	var/list/input_nodes = list()
	var/list/output_nodes = list()
	var/list/special_nodes = list()

/mob/living/proc/generate_chimeric_node_from_mob()
	var/datum/blood_type/blood = get_blood_type()
	var/datum/chimeric_table/table_type
	if(blood)
		table_type = blood.used_table
	if(!table_type)
		return null
	var/datum/chimeric_table/table = new table_type()
	var/list/available_slots = list()
	if(length(table.input_nodes))
		available_slots[INPUT_NODE] = 1
	if(length(table.output_nodes))
		available_slots[OUTPUT_NODE] = 1
	if(length(table.special_nodes))
		available_slots[SPECIAL_NODE] = 1
	if(!length(available_slots))
		available_slots = list(INPUT_NODE = 1, OUTPUT_NODE = 1, SPECIAL_NODE = 1)
	var/selected_slot = pickweight(available_slots)
	var/list/node_pool
	switch(selected_slot)
		if(INPUT_NODE)
			node_pool = table.input_nodes.Copy()
		if(OUTPUT_NODE)
			node_pool = table.output_nodes.Copy()
		if(SPECIAL_NODE)
			node_pool = table.special_nodes.Copy()

	if(!length(node_pool))
		node_pool = get_weighted_nodes_by_tier(selected_slot, table.node_tier)
	else
		var/list/tier_nodes = get_weighted_nodes_by_tier(selected_slot, table.node_tier)
		for(var/node_type in tier_nodes)
			if(node_type in node_pool)
				node_pool[node_type] += tier_nodes[node_type]
			else
				node_pool[node_type] = tier_nodes[node_type]

	if(!length(node_pool))
		qdel(table)
		return null
	var/datum/chimeric_node/selected_node_type = pickweight(node_pool)
	var/obj/item/chimeric_node/new_node = new()
	new_node.node_tier = table.node_tier
	new_node.node_purity = rand(table.node_purity_min, table.node_purity_max)
	new_node.setup_node(
		selected_node_type,
		table.compatible_blood_types,
		table.incompatible_blood_types,
		table.preferred_blood_types,
		table.base_blood_cost,
		table.preferred_blood_bonus,
		table.incompatible_blood_penalty,
	)
	qdel(table)
	return new_node

/mob/living/proc/create_chimeric_node()
	var/obj/item/chimeric_node/new_node = generate_chimeric_node_from_mob()
	new_node.forceMove(get_turf(src))
