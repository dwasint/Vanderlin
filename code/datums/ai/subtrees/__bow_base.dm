/datum/ai_planning_subtree/archer_base/proc/validate_archer_equipment(datum/ai_controller/controller)
	var/mob/living/carbon/human/pawn = controller.pawn


	if(world.time < controller.blackboard[BB_ARCHER_NPC_EQUIPMENT_CACHE_EXPIRY])
		var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/cached_bow = controller.blackboard[BB_ARCHER_NPC_BOW]
		var/obj/item/ammo_holder/quiver/cached_quiver = controller.blackboard[BB_ARCHER_NPC_QUIVER]
		if(QDELETED(cached_bow) || QDELETED(cached_quiver))
			_clear_equipment_cache(controller)
			return FALSE
		return TRUE

	_clear_equipment_cache(controller)

	var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/found_bow = null
	for(var/obj/item/I in pawn.get_active_held_items())
		if(istype(I, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
			found_bow = I
			break
	if(!found_bow)
		for(var/obj/item/I in pawn.get_equipped_items())
			if(istype(I, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
				found_bow = I
				break
	if(!found_bow)
		return FALSE

	// Find a quiver compatible with this bow's ammo
	var/ammo_check = found_bow?.magazine.ammo_type
	var/obj/item/ammo_holder/quiver/found_quiver = null
	for(var/obj/item/ammo_holder/quiver/Q in pawn.get_equipped_items())
		for(var/accepted in Q.ammo_type)
			if(ispath(ammo_check, accepted))
				found_quiver = Q
				break
		if(found_quiver)
			break
	if(!found_quiver)
		return FALSE

	controller.set_blackboard_key(BB_ARCHER_NPC_BOW, found_bow)
	controller.set_blackboard_key(BB_ARCHER_NPC_QUIVER, found_quiver)
	controller.set_blackboard_key(BB_ARCHER_NPC_EQUIPMENT_CACHE_EXPIRY, world.time + ARCHER_NPC_EQUIPMENT_CACHE_TIME)
	return TRUE

/datum/ai_planning_subtree/archer_base/proc/_clear_equipment_cache(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ARCHER_NPC_BOW)
	controller.clear_blackboard_key(BB_ARCHER_NPC_QUIVER)
	controller.clear_blackboard_key(BB_ARCHER_NPC_EQUIPMENT_CACHE_EXPIRY)
