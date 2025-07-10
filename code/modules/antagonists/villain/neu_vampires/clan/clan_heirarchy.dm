/datum/clan_hierarchy_node
	var/name = "Position"
	var/desc = "A position within the clan hierarchy"
	var/mob/living/carbon/human/assigned_member
	var/datum/clan_hierarchy_node/superior // Who this position reports to
	var/list/datum/clan_hierarchy_node/subordinates = list() // Who reports to this position
	var/rank_level = 0 // 0 = leader, higher numbers = lower ranks
	var/max_subordinates = 5 // Maximum number of direct reports
	var/can_assign_positions = FALSE // Can this position create/assign sub-positions
	var/position_color = "#ffffff"
	var/node_x = 0
	var/node_y = 0
	var/mutable_appearance/cloned_look

/datum/clan_hierarchy_node/New(position_name, position_desc, level = 1)
	name = position_name
	desc = position_desc
	rank_level = level
	..()

/datum/clan_hierarchy_node/proc/assign_member(mob/living/carbon/human/member)
	if(!member || !member.clan)
		return FALSE

	if(member.clan_position)
		member.clan_position.remove_member()

	assigned_member = member
	member.clan_position = src
	var/old_dir = member?.dir
	member?.dir = SOUTH
	cloned_look = member?.appearance
	member?.dir = old_dir
	return TRUE

/datum/clan_hierarchy_node/proc/remove_member()
	if(assigned_member)
		assigned_member.clan_position = null
		assigned_member = null
	cloned_look = null

/datum/clan_hierarchy_node/proc/add_subordinate(datum/clan_hierarchy_node/subordinate)
	if(!subordinate || subordinates.len >= max_subordinates)
		return FALSE

	subordinates += subordinate
	subordinate.superior = src
	return TRUE

/datum/clan_hierarchy_node/proc/remove_subordinate(datum/clan_hierarchy_node/subordinate)
	subordinates -= subordinate
	subordinate.superior = null

/datum/clan_hierarchy_node/proc/get_all_subordinates()
	var/list/all_subs = list()
	for(var/datum/clan_hierarchy_node/sub in subordinates)
		all_subs += sub
		all_subs += sub.get_all_subordinates()
	return all_subs

/datum/clan_hierarchy_node/proc/get_all_superiors()
	var/list/all_sups = list()
	if(superior)
		all_sups += superior
		all_sups += superior.get_all_superiors()
	return all_sups

/datum/clan_hierarchy_node/proc/get_subordinates_at_depth(depth = 1)
	if(depth <= 0)
		return list(src)

	var/list/result = list()
	if(depth == 1)
		return subordinates.Copy()

	for(var/datum/clan_hierarchy_node/sub in subordinates)
		result += sub.get_subordinates_at_depth(depth - 1)
	return result

/datum/clan_hierarchy_node/proc/get_hierarchy_root()
	if(!superior)
		return src
	return superior.get_hierarchy_root()

/datum/clan_hierarchy_node/proc/get_total_subordinate_count()
	var/count = subordinates.len
	for(var/datum/clan_hierarchy_node/sub in subordinates)
		count += sub.get_total_subordinate_count()
	return count

/datum/clan_hierarchy_node/proc/is_superior_to(datum/clan_hierarchy_node/other)
	if(!other)
		return FALSE
	var/list/other_superiors = other.get_all_superiors()
	return (src in other_superiors)

/datum/clan_hierarchy_node/proc/is_subordinate_to(datum/clan_hierarchy_node/other)
	if(!other)
		return FALSE
	var/list/other_subordinates = other.get_all_subordinates()
	return (src in other_subordinates)
