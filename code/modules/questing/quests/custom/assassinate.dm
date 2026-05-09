
/datum/quest/custom/assassinate
	quest_type = QUEST_CUSTOM
	/// real_name of the player to eliminate.
	var/target_player_name = ""

/datum/quest/custom/assassinate/get_title()
	if(title)
		return title
	return target_player_name ? "Eliminate [target_player_name]" : "Assassination Contract"

/datum/quest/custom/assassinate/get_objective_text()
	return "Find and eliminate [target_player_name ? target_player_name : "your target"]. " \
		+ "Return your contract scroll to the Notice Board for payment."

/datum/quest/custom/assassinate/get_location_text()
	return "Locate [target_player_name ? target_player_name : "your target"] yourself."

/datum/quest/custom/assassinate/generate(obj/effect/landmark/quest_spawner/landmark)
	if(!title)
		title = get_title()
	progress_required = 1
	_register_death_signals()
	return TRUE

/datum/quest/custom/assassinate/proc/_register_death_signals()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.real_name == target_player_name)
			RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
			add_tracked_atom(H)

/datum/quest/custom/assassinate/proc/on_target_death(mob/living/dead_mob, gibbed)
	SIGNAL_HANDLER
	if(complete)
		return
	var/mob/receiver = quest_receiver_reference?.resolve()
	if(!receiver)
		return
	if(dead_mob.lastattacker != receiver)
		return
	progress_current = progress_required
	mark_complete()

/datum/quest/custom/assassinate/Destroy()
	for(var/datum/weakref/ref in tracked_atoms)
		var/mob/living/M = ref.resolve()
		if(M)
			UnregisterSignal(M, COMSIG_LIVING_DEATH)
	return ..()
