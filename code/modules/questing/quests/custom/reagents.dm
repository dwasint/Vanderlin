#define CUSTOM_MODE_REAGENT "reagent"

/datum/quest/custom/reagent
	custom_mode = CUSTOM_MODE_REAGENT

	var/reagent_type_path = null  // type path, e.g. /datum/reagent/consumable/coffee
	var/reagent_name = ""
	var/reagent_volume_required = 10
	var/reagent_volume_current = 0


/datum/quest/custom/reagent/get_title()
	if(title)
		return title
	return "Procure [reagent_volume_required] ligulae of [reagent_name ? reagent_name : "reagent"]"

/datum/quest/custom/reagent/get_objective_text()
	return "Bring [reagent_volume_required] ligulae of [reagent_name] (in any container) to \
		[quest_giver_name ? quest_giver_name : "the steward"]'s drop-off point."

/datum/quest/custom/reagent/generate(obj/effect/landmark/quest_spawner/landmark)
	if(!title)
		title = get_title()
	if(landmark)
		var/datum/threat_region/TR = SSregionthreat.get_region_for_turf(get_turf(landmark))
		if(TR)
			threat_region_name = TR.region_name
	progress_required = reagent_volume_required
	return TRUE

/datum/quest/custom/reagent/check_completion()
	return reagent_volume_current >= reagent_volume_required

/// Scans every atom on input_point for the target reagent,
/// marks complete if the threshold is met.
/// Returns TRUE if the quest was completed by this turn-in.
/datum/quest/custom/reagent/proc/check_reagent_turnin(turf/input_point)
	if(!reagent_type_path || complete)
		return FALSE

	// Tally up available volume across all containers on the marker
	var/total = 0
	for(var/atom/movable/A in input_point)
		if(!A.reagents)
			continue
		if(!A.reagents.has_reagent(reagent_type_path))
			continue
		total += A.reagents.get_reagent_amount(reagent_type_path)

	if(total < reagent_volume_required)
		return FALSE

	// Package up all containers that have the reagent
	var/obj/item/quest_package/P = new(input_point)
	P.name = "quest parcel ([reagent_name])"
	P.quest_title = title
	P.pledge_ref = pledge_ref

	for(var/atom/movable/A in input_point)
		if(A == P)
			continue
		if(!A.reagents?.has_reagent(reagent_type_path))
			continue
		A.forceMove(P)

	progress_current = reagent_volume_required
	mark_complete()
	return TRUE

#undef CUSTOM_MODE_REAGENT
