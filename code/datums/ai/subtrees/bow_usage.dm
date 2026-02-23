/datum/ai_planning_subtree/ranged_attack_subtree
	parent_type = /datum/ai_planning_subtree/archer_base

/datum/ai_planning_subtree/ranged_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!validate_archer_equipment(controller))
		return
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || !isliving(target))
		return
	if(get_dist(pawn, target) < ARCHER_NPC_MIN_RANGE)
		return
	var/obj/item/ammo_holder/quiver/Q = controller.blackboard[BB_ARCHER_NPC_QUIVER]
	if(!Q.ammo_list.len)
		return

	controller.queue_behavior(/datum/ai_behavior/ranged_attack_bow, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/ranged_attack_bow
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 0.2 SECONDS

/datum/ai_behavior/ranged_attack_bow/setup(datum/ai_controller/controller, target_key)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return FALSE

	// Stash held melee weapon if needed so both hands are free for the bow
	for(var/obj/item/held in pawn.get_active_held_items())
		if(istype(held, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
			continue
		if(!held)
			continue
		var/stashed = FALSE
		for(var/slot in list(ITEM_SLOT_BACK, ITEM_SLOT_HIP, ITEM_SLOT_BELT_L, ITEM_SLOT_BACK_L, ITEM_SLOT_BACK_R, ITEM_SLOT_BELT_R))
			if(!pawn.get_item_by_slot(slot))
				if(pawn.equip_to_slot_if_possible(held, slot, disable_warning = TRUE))
					controller.set_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON, held)
					stashed = TRUE
					break
		if(!stashed)
			controller.clear_blackboard_key(BB_ARCHER_NPC_QUIVER) //this is weird you might say? but it saves a memory slot since it cannot execute a bow shot without a quiver causing it to go on cooldown for 40 seconds.
			return FALSE

	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/bow = null
	for(var/obj/item/held in pawn.get_active_held_items())
		if(istype(held, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
			bow = held
			break
	if(!bow)
		for(var/obj/item/worn in pawn.get_equipped_items())
			if(istype(worn, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
				pawn.put_in_active_hand(worn)
				bow = worn
				break
	if(!bow)
		return FALSE

	if(!bow.chambered)
		var/ammo_check = bow.magazine.ammo_type
		for(var/obj/item/ammo_holder/quiver/Q in pawn.get_equipped_items())
			if(!Q.ammo_list.len)
				continue
			for(var/obj/item/ammo_casing/arrow in Q.ammo_list)
				if(ispath(arrow.type, ammo_check))
					Q.ammo_list -= arrow
					arrow.forceMove(bow)
					// Mirror what attackby does for loading
					bow.attackby(arrow, pawn, null)
					break
			break

	if(!bow.chambered)
		return FALSE

	// For crossbows, ensure cocked
	if(istype(bow, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
		var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/xbow = bow
		if(!xbow.cocked)
			xbow.cocked = TRUE
			xbow.update_appearance(UPDATE_ICON_STATE)

	var/chargetime = ARCHER_NPC_SIMULATED_CHARGETIME
	if(pawn.used_intent && pawn.used_intent.chargetime)
		chargetime = pawn.used_intent.get_chargetime()
	controller.set_blackboard_key(BB_ARCHER_NPC_CHARGE_TIMER, world.time + (chargetime))

	return TRUE

/datum/ai_behavior/ranged_attack_bow/perform(delta_time, datum/ai_controller/controller, target_key)
	var/mob/living/carbon/human/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(!target || (ismob(target) && target:stat == DEAD))
		finish_action(controller, FALSE, target_key)
		return

	// Break off if target closed to melee range
	if(get_dist(pawn, target) < ARCHER_NPC_MIN_RANGE)
		finish_action(controller, FALSE, target_key)
		return

	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/bow = null
	for(var/obj/item/held in pawn.get_active_held_items())
		if(istype(held, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
			bow = held
			break
	if(!bow || !bow.chambered)
		finish_action(controller, FALSE, target_key)
		return

	// Wait for simulated charge since we have no client
	if(world.time < controller.blackboard[BB_ARCHER_NPC_CHARGE_TIMER])
		pawn.face_atom(target)
		return

	pawn.face_atom(target)
	controller.ai_interact(target, TRUE, TRUE)

	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/ranged_attack_bow/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/carbon/human/pawn = controller.pawn

	controller.clear_blackboard_key(BB_ARCHER_NPC_CHARGE_TIMER)

	// Re-equip stashed melee weapon
	var/obj/item/stashed = controller.blackboard[BB_ARCHER_NPC_STASHED_WEAPON]
	if(stashed && !QDELETED(stashed))
		if(!pawn.get_active_held_item())
			pawn.dropItemToGround(stashed, TRUE, TRUE)
			pawn.put_in_active_hand(stashed)
		else if(!pawn.get_inactive_held_item())
			pawn.dropItemToGround(stashed, TRUE, TRUE)
			pawn.put_in_inactive_hand(stashed)
	controller.clear_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON)
