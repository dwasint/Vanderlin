#define CUSTOM_MODE_ITEM "item"
#define CUSTOM_MODE_FREEFORM "freeform"

/datum/quest/custom
	quest_type = QUEST_CUSTOM
	quest_difficulty = QUEST_DIFFICULTY_EASY
	var/custom_mode = CUSTOM_MODE_FREEFORM
	var/obj/item/custom_item_type
	var/custom_item_name = ""
	var/custom_item_count = 1
	var/custom_objective_text = ""
	var/steward_validated = FALSE

	/// Weakref to the /obj/item/paper/scroll/quest/pledge that created this quest, if any.
	var/datum/weakref/pledge_ref

/datum/quest/custom/get_title()
	if(title)
		return title
	if(custom_mode == CUSTOM_MODE_ITEM)
		return "Procure [custom_item_count > 1 ? "[custom_item_count]x " : ""][custom_item_name]"
	return "Special Commission"

/datum/quest/custom/get_objective_text()
	if(custom_mode == CUSTOM_MODE_ITEM)
		return "Bring [custom_item_count] [custom_item_name] to [quest_giver_name ? quest_giver_name : "the steward"]."
	return custom_objective_text ? custom_objective_text : "Speak with [quest_giver_name ? quest_giver_name : "the steward"] for details."

/datum/quest/custom/get_location_text()
	return "Speak to [quest_giver_name ? quest_giver_name : "the steward"] for instructions."

/datum/quest/custom/generate(obj/effect/landmark/quest_spawner/landmark)
	if(!title)
		title = get_title()
	if(landmark)
		var/datum/threat_region/TR = SSregionthreat.get_region_for_turf(get_turf(landmark))
		if(TR)
			threat_region_name = TR.region_name
	progress_required = (custom_mode == CUSTOM_MODE_ITEM) ? custom_item_count : 1
	return TRUE

/datum/quest/custom/check_completion()
	if(custom_mode == CUSTOM_MODE_ITEM)
		return progress_current >= progress_required
	return steward_validated

/datum/quest/custom/proc/steward_validate(mob/steward)
	if(!ishuman(steward))
		return FALSE
	var/datum/job/steward_job = steward.job ? SSjob.GetJob(steward.job) : null
	if(!steward_job?.is_quest_giver)
		to_chat(steward, span_warning("Only a quest-issuing role can validate quests."))
		return FALSE
	if(complete)
		to_chat(steward, span_notice("This quest is already complete."))
		return FALSE
	steward_validated = TRUE
	log_quest(steward.ckey, steward.mind, steward, "Validate custom quest: [title]")
	mark_complete()
	to_chat(steward, span_notice("You validate \"[title]\" as complete."))
	return TRUE

/datum/quest/custom/proc/check_item_turnin(list/items_on_marker, turf/input_point)
	if(custom_mode != CUSTOM_MODE_ITEM || !custom_item_type)
		return FALSE
	var/count = 0
	for(var/obj/item/I in items_on_marker)
		if(istype(I, custom_item_type))
			count++
	if(count < custom_item_count)
		return FALSE

	var/obj/item/quest_package/P = new(input_point)
	P.name = "quest parcel ([custom_item_name])"
	P.quest_title = title
	// If this was pledge-backed, store the ref so only that pledgee(?) can open it.
	P.pledge_ref = pledge_ref

	var/consumed = 0
	for(var/obj/item/I in items_on_marker)
		if(istype(I, custom_item_type) && consumed < custom_item_count)
			I.forceMove(P)
			consumed++

	progress_current = progress_required
	mark_complete()
	return TRUE

#undef CUSTOM_MODE_ITEM
#undef CUSTOM_MODE_FREEFORM
