/proc/get_weighted_nodes_by_tier(slot_type, max_tier)
	var/list/weighted_nodes = list()
	var/list/node_types

	switch(slot_type)
		if(INPUT_NODE)
			node_types = subtypesof(/datum/chimeric_organs/input)
		if(OUTPUT_NODE)
			node_types = subtypesof(/datum/chimeric_organs/output)
		if(SPECIAL_NODE)
			node_types = subtypesof(/datum/chimeric_organs/special)
		else
			return weighted_nodes

	for(var/datum/chimeric_organs/node_type as anything in node_types)
		if(is_abstract(node_type))
			continue
		var/tier = initial(node_type.tier)
		if(tier > max_tier)
			continue
		weighted_nodes[node_type] = initial(node_type.weight)

	return weighted_nodes

/datum/chimeric_organs
	abstract_type = /datum/chimeric_organs
	var/name = ""
	var/desc = ""

	var/slot = INPUT_NODE
	var/is_special = FALSE
	var/node_purity = 100
	var/tier = 1
	var/weight = 10
	var/obj/item/organ/attached_organ
	var/mob/living/carbon/hosted_carbon
	///a special node that interacts with either the input or output
	var/datum/chimeric_organs/special/attached_special

	/// Blood types this node can use (empty = can use any)
	var/list/compatible_blood_types = list()
	/// Blood types that provide bonus efficiency
	var/list/preferred_blood_types = list()
	/// Blood types that harm the node/host
	var/list/incompatible_blood_types = list()

	/// Base blood stability consumed per second by this node
	var/base_blood_cost = 0.3
	/// Efficiency bonus when using preferred blood (0.5 = 50% reduction)
	var/preferred_blood_bonus = 0.5
	/// Penalty when using incompatible blood (2.0 = double cost)
	var/incompatible_blood_penalty = 2.0

	// List of organ slots this node can be installed in (empty = any organ)
	///ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, etc.
	var/list/allowed_organ_slots = list()
	/// List of organ slots this node is explicitly forbidden from
	var/list/forbidden_organ_slots = list()

/datum/component/chimeric_organ/proc/check_node_compatibility(datum/chimeric_organs/node)
	var/obj/item/organ/organ = parent
	if(!istype(organ))
		return FALSE

	// Check if node has forbidden slots
	if(length(node.forbidden_organ_slots))
		if(organ.slot in node.forbidden_organ_slots)
			return FALSE

	// Check if node has allowed slots restriction
	if(length(node.allowed_organ_slots))
		if(!(organ.slot in node.allowed_organ_slots))
			return FALSE

	return TRUE

/datum/chimeric_organs/proc/try_consume_blood(datum/component/blood_stability/blood_stab, delta_time)
	var/blood_needed = base_blood_cost * delta_time

	for(var/blood_type in preferred_blood_types)
		var/adjusted_cost = blood_needed * (1 - preferred_blood_bonus)
		if(blood_stab.consume_stability(blood_type, adjusted_cost))
			return TRUE

	if(length(compatible_blood_types))
		for(var/blood_type in compatible_blood_types)
			if(blood_stab.consume_stability(blood_type, blood_needed))
				return TRUE
	else
		for(var/blood_type in blood_stab.blood_stability)
			if(blood_type in incompatible_blood_types)
				continue
			if(blood_stab.consume_stability(blood_type, blood_needed))
				return TRUE

	for(var/blood_type in incompatible_blood_types)
		var/adjusted_cost = blood_needed * (1 + incompatible_blood_penalty)
		if(blood_stab.consume_stability(blood_type, adjusted_cost))
			damage_from_incompatible_blood()
			return TRUE

	return FALSE

/datum/chimeric_organs/proc/damage_from_incompatible_blood()
	if(!hosted_carbon)
		return

	if(prob(10))
		to_chat(hosted_carbon, span_danger("Your grafted flesh rejects the incompatible blood!"))
		attached_organ.applyOrganDamage(1)


/datum/chimeric_organs/proc/setup()
	return

/datum/chimeric_organs/proc/set_ranges()
	return

/datum/chimeric_organs/proc/return_description(skill_level)
	return

/datum/chimeric_organs/proc/check_active()
	return

/datum/chimeric_organs/proc/set_values(node_purity, tier)
	src.node_purity = node_purity
	src.tier = tier

	set_ranges()
