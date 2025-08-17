/datum/gnome_state/transport
	name = "transport"
	description = "Moving items between waypoints"
	var/current_task = "finding_item"

/datum/gnome_state/transport/enter_state(datum/ai_controller/controller)
	current_task = "finding_item"

/datum/gnome_state/transport/process_state(datum/ai_controller/controller, delta_time)
	if(!controller.blackboard[BB_GNOME_TRANSPORT_MODE])
		return GNOME_STATE_COMPLETE

	var/mob/living/pawn = controller.pawn

	switch(current_task)
		if("finding_item")
			var/obj/item/carried = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
			if(carried)
				current_task = "delivering"
				return GNOME_STATE_CONTINUE

			var/obj/item/found_item = find_transport_item(controller)
			if(!found_item)
				return GNOME_STATE_CONTINUE

			controller.set_blackboard_key(BB_GNOME_FOUND_ITEM, found_item)
			controller.set_movement_target(found_item)
			current_task = "picking_up"
			return GNOME_STATE_CONTINUE

		if("picking_up")
			var/obj/item/found_item = controller.blackboard[BB_GNOME_FOUND_ITEM]
			if(!found_item)
				current_task = "finding_item"
				return GNOME_STATE_CONTINUE

			if(get_dist(pawn, found_item) > 1)
				return GNOME_STATE_CONTINUE

			if(found_item.forceMove(pawn))
				controller.set_blackboard_key(BB_SIMPLE_CARRY_ITEM, found_item)
				controller.clear_blackboard_key(BB_GNOME_FOUND_ITEM)
				pawn.visible_message(span_notice("[pawn] picks up [found_item]."))
				current_task = "delivering"
			else
				current_task = "finding_item"

			return GNOME_STATE_CONTINUE

		if("delivering")
			var/turf/dest = controller.blackboard[BB_GNOME_TRANSPORT_DEST]
			if(!dest)
				return GNOME_STATE_FAILED

			if(get_dist(pawn, dest) > 1)
				controller.set_movement_target(dest)
				return GNOME_STATE_CONTINUE

			current_task = "dropping"
			return GNOME_STATE_CONTINUE

		if("dropping")
			var/obj/item/carried = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
			var/turf/dest = controller.blackboard[BB_GNOME_TRANSPORT_DEST]

			if(!carried)
				current_task = "finding_item"
				return GNOME_STATE_CONTINUE

			pawn.dropItemToGround(carried)
			carried.forceMove(dest)
			controller.clear_blackboard_key(BB_SIMPLE_CARRY_ITEM)
			pawn.visible_message(span_notice("[pawn] carefully sets down [carried]."))
			current_task = "finding_item"
			return GNOME_STATE_CONTINUE

	return GNOME_STATE_CONTINUE

/datum/gnome_state/transport/proc/find_transport_item(datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = controller.pawn
	var/turf/source = controller.blackboard[BB_GNOME_TRANSPORT_SOURCE]
	var/range = controller.blackboard[BB_GNOME_SEARCH_RANGE] || 1

	if(!source)
		return null

	for(var/turf/check_turf in view(range, source))
		for(var/obj/item/I in check_turf.contents)
			if(I.anchored)
				continue
			if(I.w_class > gnome.max_carry_size)
				continue
			if(!gnome.item_matches_filter(I))
				continue
			return I

	return null
