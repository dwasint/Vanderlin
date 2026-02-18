/datum/component/ghost_vessel
	var/obj/item/vessel_item_type    // The item type that "unlocks" the mob
	var/mob/living/carbon/human/owner
	var/being_offered = FALSE

/datum/component/ghost_vessel/Initialize(obj/item/item_type)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	vessel_item_type = item_type

	ADD_TRAIT(owner, TRAIT_STASIS, REF(src))
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, SOULSTONE_TRAIT)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, SOULSTONE_TRAIT)

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_deleted))

/datum/component/ghost_vessel/Destroy()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_STASIS, REF(src))
		REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, SOULSTONE_TRAIT)
		REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, SOULSTONE_TRAIT)
	owner = null
	return ..()

/datum/component/ghost_vessel/proc/on_parent_deleted(datum/source)
	return

/datum/component/ghost_vessel/proc/on_attackby(datum/source, obj/item/W, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(W, vessel_item_type))
		return
	if(being_offered)
		return
	qdel(W)
	INVOKE_ASYNC(src, PROC_REF(begin_ghost_offer))

/datum/component/ghost_vessel/proc/begin_ghost_offer()
	being_offered = TRUE

	var/list/candidates = pollCandidatesForMob(
		"A vessel at [owner.loc] awaits a soul. Do you wish to inhabit it?",
		null,
		null,
		null,
		100,
		parent,
		POLL_IGNORE_GOLEM,
		new_players = TRUE
	)

	if(length(candidates))
		var/mob/dead/observer/chosen = candidates[1]
		possess_vessel(chosen)
	else
		owner.balloon_alert_to_viewers("This vessel awaits a soul...")
		add_ghost_verb()

/datum/component/ghost_vessel/proc/possess_vessel(mob/dead/observer/ghost)
	if(!ghost?.client)
		return

	being_offered = FALSE
	REMOVE_TRAIT(owner, TRAIT_STASIS, REF(src))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, SOULSTONE_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, SOULSTONE_TRAIT)
	owner.key = ghost.client.key
	qdel(src)

/datum/component/ghost_vessel/proc/add_ghost_verb()
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine_by_ghost))

/datum/component/ghost_vessel/proc/on_examine_by_ghost(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!istype(user, /mob/dead/observer))
		return
	examine_list += span_notice("<b>This vessel is empty. Inhabit it (Orbit Mob)?</b>")
	RegisterSignal(user, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(on_ghost_ctrl_click))  // alt: add a verb

/datum/component/ghost_vessel/proc/on_ghost_ctrl_click(datum/source, mob/living/clicker)
	var/option = browser_input_list(clicker, "Do you wish to possess this vessel??", "XYLIX", DEFAULT_INPUT_CHOICES)
	if(!option)
		return
	if(!istype(clicker, /mob/dead/observer))
		return
	if(!being_offered)
		return
	INVOKE_ASYNC(src, PROC_REF(possess_vessel), clicker)
