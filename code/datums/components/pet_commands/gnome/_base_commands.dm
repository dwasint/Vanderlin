// ===============================
// PET COMMANDS
// ===============================

// Base gnome command
/datum/pet_command/gnome
	command_feedback = "*looks*"
	sense_radius = 9
	radial_icon = 'icons/hud/radial_pets.dmi'

/datum/pet_command/gnome/move_item
	command_name = "Move Item"
	command_desc = "Move items between set waypoints"
	radial_icon_state = "move-item"
	speech_commands = list("move", "transport", "carry", "transfer")

/datum/pet_command/gnome/move_item/execute_action(datum/ai_controller/controller)
	var/turf/waypoint_a = controller.blackboard[BB_GNOME_WAYPOINT_A]
	var/turf/waypoint_b = controller.blackboard[BB_GNOME_WAYPOINT_B]

	if(!waypoint_a || !waypoint_b)
		var/mob/living/pawn = controller.pawn
		pawn.visible_message(span_warning("[pawn] looks confusedly - not enough waypoints set!"))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return

	controller.set_blackboard_key(BB_GNOME_TRANSPORT_MODE, TRUE)
	controller.set_blackboard_key(BB_GNOME_TRANSPORT_SOURCE, waypoint_a)
	controller.set_blackboard_key(BB_GNOME_TRANSPORT_DEST, waypoint_b)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/gnome/stop_move_item
	command_name = "Stop Move Item"
	command_desc = "Stop moving items"
	radial_icon_state = "move-item-stop"
	speech_commands = list("stop moving", "stop transport", "halt")

/datum/pet_command/gnome/stop_move_item/execute_action(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	controller.set_blackboard_key(BB_GNOME_TRANSPORT_MODE, FALSE)
	controller.clear_blackboard_key(BB_GNOME_TRANSPORT_SOURCE)
	controller.clear_blackboard_key(BB_GNOME_TRANSPORT_DEST)
	pawn.visible_message(span_notice("[pawn] stops moving items and returns to normal behavior."))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/gnome/set_waypoint
	command_name = "Set Waypoint A"
	command_desc = "Set a waypoint at pointed location"
	radial_icon_state = "point"
	speech_commands = list("waypoint", "mark", "remember", "point")
	requires_pointing = TRUE
	pointed_reaction = "and commits the location to memory"
	var/key = BB_GNOME_WAYPOINT_A

/datum/pet_command/gnome/set_waypoint/execute_action(datum/ai_controller/controller)
	var/turf/target = get_turf(controller.blackboard[BB_CURRENT_PET_TARGET])
	if(!target)
		return

	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = controller.pawn
	if(!istype(gnome))
		return

	var/turf/old = controller.blackboard[key]
	if(old)
		gnome.waypoints -= old

	gnome.waypoints |= target
	gnome.visible_message(span_notice("[gnome] looks and nods, marking this location."))
	controller.set_blackboard_key(key, target)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/gnome/set_waypoint/b
	command_name = "Set Waypoint B"
	command_desc = "Set a second waypoint at pointed location"
	radial_icon_state = "point-b"
	key = BB_GNOME_WAYPOINT_B


/datum/pet_command/gnome/set_filter
	command_name = "Set Filter"
	command_desc = "Set item filter for transportation"
	radial_icon_state = "filter"
	speech_commands = list("filter", "only move", "sort")
	requires_pointing = TRUE
	pointed_reaction = "and analyzes the item carefully"

/datum/pet_command/gnome/set_filter/execute_action(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[BB_CURRENT_PET_TARGET]
	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = controller.pawn
	if(!target || !istype(gnome))
		return

	gnome.item_filters += target.type
	gnome.visible_message(span_notice("[gnome] looks and will now prioritize [target.name] items."))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/gnome/clear_filter
	command_name = "Clear Filter"
	command_desc = "Remove all item filters"
	radial_icon_state = "filter-stop"
	speech_commands = list("clear filter", "no filter", "move all", "reset filter")

/datum/pet_command/gnome/clear_filter/execute_action(datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = controller.pawn
	if(!istype(gnome))
		return

	gnome.item_filters = list()
	gnome.visible_message(span_notice("[gnome] looks and will now move any item it can carry."))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/ai_behavior/gnome_transport_cycle
	behavior_flags =  AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/gnome_transport_cycle/setup(datum/ai_controller/controller)
	. = ..()
	var/obj/item/carried_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carried_item)
		var/turf/dest = determine_delivery_location(controller, carried_item)
		if(!dest)
			return
		set_movement_target(controller, dest)
	else
		var/obj/item/found_item = find_transport_item(controller)
		if(!found_item)
			return
		controller.set_blackboard_key(BB_GNOME_FOUND_ITEM, found_item)
		set_movement_target(controller, found_item)

	return TRUE

/datum/ai_behavior/gnome_transport_cycle/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/obj/item/carried_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	var/mob/living/pawn = controller.pawn
	var/turf/dest = determine_delivery_location(controller, carried_item)

	if(carried_item && get_dist(pawn, dest) <= 1)
		pawn.dropItemToGround(carried_item)
		carried_item.forceMove(dest)
		controller.clear_blackboard_key(BB_SIMPLE_CARRY_ITEM)
		controller.clear_blackboard_key(BB_GNOME_FOUND_ITEM)
		pawn.visible_message(span_notice("[pawn] carefully sets down [carried_item]."))
		finish_action(controller, TRUE)
		return

	var/obj/item/found_item = controller.blackboard[BB_GNOME_FOUND_ITEM]
	if(!found_item)
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(BB_GNOME_FOUND_ITEM, found_item)

	if(found_item.forceMove(pawn))
		controller.set_blackboard_key(BB_SIMPLE_CARRY_ITEM, found_item)
		pawn.visible_message(span_notice("[pawn] picks up [found_item]."))
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)



/datum/ai_behavior/gnome_transport_cycle/proc/find_transport_item(datum/ai_controller/controller)
	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = controller.pawn
	var/turf/source = controller.blackboard[BB_GNOME_TRANSPORT_SOURCE]
	var/range = controller.blackboard[BB_GNOME_SEARCH_RANGE]
	var/list/turfs = view(range, source)
	turfs |= source

	if(!source)
		return null

	for(var/turf/turf in turfs)
		for(var/turf/check_turf in view(controller.blackboard[BB_GNOME_SEARCH_RANGE], turf))
			for(var/obj/item/I in check_turf.contents)
				if(I.anchored)
					continue
				if(I.w_class > gnome.max_carry_size)
					continue
				if(!gnome.item_matches_filter(I))
					continue
				return I
	return null

/datum/ai_behavior/gnome_transport_cycle/proc/determine_delivery_location(datum/ai_controller/controller, obj/item/carried_item)
	var/turf/dest = controller.blackboard[BB_GNOME_TRANSPORT_DEST]

	if(!dest)
		return null

	return dest

/datum/ai_behavior/gnome_transport_cycle/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	controller.clear_blackboard_key(BB_GNOME_FOUND_ITEM)

/datum/ai_behavior/gnome/return_home
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/gnome/return_home/setup(datum/ai_controller/controller)
	. = ..()
	var/turf/home_turf = controller.blackboard[BB_GNOME_HOME_TURF]
	if(!home_turf)
		return FALSE
	set_movement_target(controller, home_turf)

/datum/ai_behavior/gnome/return_home/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/turf/home_turf = controller.blackboard[BB_GNOME_HOME_TURF]

	if(get_turf(pawn) == home_turf)
		finish_action(controller, TRUE)

/datum/pet_command/gnome/search_range
	command_name = "Transport Search Range"
	command_desc = "Change the range at which the gnome looks for items"
	radial_icon_state = "range"
	speech_commands = list("range")

/datum/pet_command/gnome/search_range/try_activate_command(mob/living/commander, radial_command) // this is shit but it feels easier to use for players
	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = weak_parent.resolve()
	var/datum/ai_controller/controller = gnome.ai_controller

	if(!commander)
		return

	var/choice = input(commander, "Choose a range for your gnome to look for items", "Search Range") as num|null

	if(!choice || choice <= 0)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return

	if(choice >10)
		choice = 10

	controller.set_blackboard_key(BB_GNOME_SEARCH_RANGE, choice)
	gnome.visible_message(span_notice("[gnome] nods."))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/gnome/set_priority
	command_name = "Set Task Priority"
	command_desc = "Choose which tasks the gnome should prefer when multiple are active"
	radial_icon_state = "priority"
	speech_commands = list("priority", "prefer", "order tasks", "task order")

/datum/pet_command/gnome/set_priority/try_activate_command(mob/living/commander, radial_command)
	var/mob/living/simple_animal/hostile/gnome_homunculus/gnome = weak_parent.resolve()
	if(!gnome || !commander)
		return

	var/datum/ai_controller/controller = gnome.ai_controller
	var/datum/action_state_manager/manager = controller.blackboard[BB_ACTION_STATE_MANAGER]
	if(!manager)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return

	// Force a fresh priority evaluation so get_active_state_names() is accurate.
	manager.notify_priority_change()

	var/list/active = manager.get_active_state_names(controller)
	if(!active.len)
		to_chat(commander, span_warning("[gnome] has no active tasks to prioritize!"))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return

	if(active.len == 1)
		to_chat(commander, span_notice("[gnome] is only doing one thing right now, nothing to reorder."))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return

	// Build human-readable display names.
	var/list/display_names = list()
	var/list/display_to_state = list() // display_name → state_name

	// Mapping from internal state name to friendly label shown to the player.
	var/list/labels = list(
		"transport" = "Move Items (transport)",
		"farming" = "Tend Crops (farming)",
		"alchemy" = "Brew Potions (alchemy)",
		"splitter" = "Feed Splitter (splitter)",
	)

	for(var/state_name in active)
		var/label = labels[state_name] || state_name
		display_names += label
		display_to_state[label] = state_name

	// Iterative pick loop — player picks most-important first.
	var/list/ranked = list()
	var/list/remaining = display_names.Copy()

	to_chat(commander, span_notice("[gnome] awaits your instructions. Pick tasks in order of importance (most important first)."))

	while(remaining.len > 1)
		var/pick_number = ranked.len + 1
		var/suffix = pick_number == 1 ? "st" : (pick_number == 2 ? "nd" : (pick_number == 3 ? "rd" : "th"))
		var/chosen = input(
			commander,
			"Pick the [pick_number][suffix] most important task ([remaining.len] remaining):",
			"Task Priority: Step [pick_number] of [display_names.len]"
		) as null|anything in remaining

		if(!chosen)
			// no chosen, apply whatever ranking we have so far,
			// treating unranked tasks as equal lowest priority.
			break

		ranked += display_to_state[chosen]
		remaining -= chosen

	// Append any unranked tasks at equal lowest priority (offset 0).
	for(var/label in remaining)
		ranked += display_to_state[label]

	manager.apply_priority_ranking(controller, ranked)

	// Confirm to the player with the final order.
	var/list/confirm_lines = list()
	for(var/i in 1 to ranked.len)
		var/state_name = ranked[i]
		var/label = labels[state_name] || state_name
		confirm_lines += "[i]. [label]"

	gnome.visible_message(span_notice("[gnome] nods firmly, having been given a task order."))
	to_chat(commander, span_notice("Task priority set:\n[confirm_lines.Join("\n")]"))

	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
