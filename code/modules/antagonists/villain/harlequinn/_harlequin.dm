/datum/antagonist/harlequinn
	name = "Harlequinn"
	roundend_category = "Harlequinn"
	antagpanel_category = "Harlequinn"
	job_rank = ROLE_HARLEQUINN
	antag_hud_name = "harlequinn"
	confess_lines = list(
		"I was just fulfilling contracts!",
		"The bounties called to me!",
		"I only take what jobs pay well!",
	)
	var/list/available_contracts = list()
	var/list/active_contracts = list()
	var/list/completed_contracts = list()
	var/reputation = 0
	var/total_earnings = 0

/datum/antagonist/harlequinn/on_gain()
	. = ..()
	if(owner?.current)
		equip_harlequinn()
		give_objectives()

/datum/antagonist/harlequinn/proc/equip_harlequinn()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	H.unequip_everything()
	H.equipOutfit(/datum/outfit/harlequin)


/datum/antagonist/harlequinn/proc/give_objectives()
	var/mob/living/carbon/human/H = owner?.current
	if(!H)
		return

	// Collect all concrete harlequinn objective subtypes
	var/list/available_types = list()
	for(var/datum/quest/custom/harlequinn_objective/T as anything in subtypesof(/datum/quest/custom/harlequinn_objective))
		if(IS_ABSTRACT(T))
			continue
		available_types += T

	if(!length(available_types))
		// Fallback: plain survive
		var/datum/objective/survive/surv = new()
		surv.owner = owner
		objectives += surv
		return

	// Shuffle and try up to 3
	available_types = shuffle(available_types)
	var/assigned = 0
	for(var/quest_type as anything in available_types)
		if(assigned >= 3)
			break

		var/datum/quest/custom/harlequinn_objective/OQ = new quest_type()
		OQ.owning_harlequinn = WEAKREF(src)
		OQ.generate(null)

		if(!OQ.setup_for_harlequinn(src))
			qdel(OQ)
			continue

		// Wrap in a standard objective so the antag panel works normally
		var/datum/objective/harlequinn_contract/obj = new()
		obj.owner = owner
		// Re-use harlequinn_contract objective but point it at the quest datum
		// via a small shim — see below
		obj.explanation_text = OQ.get_objective_text()
		obj.linked_quest = WEAKREF(OQ)
		objectives += obj

		// Store on the antag for later reference
		active_contracts += OQ
		assigned++

	if(!assigned)
		var/datum/objective/survive/surv = new()
		surv.owner = owner
		objectives += surv

/datum/objective/harlequinn_contract
	var/datum/weakref/linked_quest // weakref to /datum/quest/custom/harlequinn_objective

/datum/objective/harlequinn_contract/check_completion()
	var/datum/quest/custom/harlequinn_objective/OQ = linked_quest?.resolve()
	if(OQ && !QDELETED(OQ))
		return OQ.check_completion()
	return FALSE

/obj/item/harlequinn_disguise_kit
	name = "professional disguise kit"
	desc = "A collection of makeup, prosthetics, and costume pieces for mundane disguises."
	//icon = 'icons/obj/items.dmi'
	icon_state = "disguise_kit"
	w_class = WEIGHT_CLASS_NORMAL
	grid_width = 32
	grid_height = 32

/obj/item/harlequinn_disguise_kit/attack_self(mob/user, list/modifiers)
	var/list/options = list(
		"Quick Disguise" = "quick",
		"Detailed Disguise" = "detailed",
		"Remove Disguise" = "remove"
	)

	var/choice = input(user, "What would you like to do?", "Disguise Kit") as null|anything in options
	if(!choice)
		return

	switch(options[choice])
		if("quick")
			quick_disguise(user)
		if("detailed")
			detailed_disguise(user)
		if("remove")
			remove_disguise(user)

/obj/item/harlequinn_disguise_kit/proc/quick_disguise(mob/user)
	to_chat(user, span_notice("You quickly apply a basic disguise..."))
	if(do_after(user, 30 SECONDS, target = user))
		user.name = "Unknown"
		to_chat(user, span_notice("You look like a different person, though the disguise won't fool close inspection."))

/obj/item/harlequinn_disguise_kit/proc/detailed_disguise(mob/user)
	var/new_name = browser_input_text(user, "What name should you appear as?", "DISGUISE", max_length = MAX_NAME_LEN)
	if(!new_name)
		return

	to_chat(user, span_notice("You carefully apply an elaborate disguise..."))
	if(do_after(user, 120 SECONDS, target = user))
		user.name = new_name
		to_chat(user, span_notice("Your disguise is convincing and should fool most observers."))

/obj/item/harlequinn_disguise_kit/proc/remove_disguise(mob/user)
	to_chat(user, span_notice("You remove your disguise..."))
	if(do_after(user, 15 SECONDS, target = user))
		user.name = user.real_name
		to_chat(user, span_notice("You return to your normal appearance."))

/obj/structure/buried_cache
	name = "buried cache"
	desc = "Something has been buried here."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt_cache"
	anchored = TRUE
	density = FALSE
	var/list/cached_items = list()
	var/cache_id
	var/buried_by

/obj/structure/buried_cache/Initialize(mapload, id, buried_by_name)
	. = ..()
	cache_id = id
	buried_by = buried_by_name

	if(cache_id && GLOB.persistent_caches[cache_id])
		cached_items = GLOB.persistent_caches[cache_id]

/obj/structure/buried_cache/attack_hand(mob/user)
	if(!length(cached_items))
		to_chat(user, span_notice("You dig around but find nothing."))
		return

	to_chat(user, span_notice("You begin digging up the buried cache..."))
	if(do_after(user, 30 SECONDS, target = src))
		for(var/obj/item/I in cached_items)
			I.forceMove(get_turf(src))
		cached_items = list()
		to_chat(user, span_notice("You unearth the buried items!"))
		qdel(src)

/obj/structure/buried_cache/proc/bury_item(obj/item/I, mob/user)
	I.forceMove(src)
	cached_items += I

	if(!GLOB.persistent_caches)
		GLOB.persistent_caches = list()
	GLOB.persistent_caches[cache_id] = cached_items

	to_chat(user, span_notice("You bury [I] in the cache."))

GLOBAL_LIST_EMPTY(persistent_caches)
