
/datum/ai_planning_subtree/haul_food_to_young/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_FOOD_TO_DELIVER))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_hands/given_list, BB_FOOD_TO_DELIVER, controller.blackboard[BB_HUNTABLE_PREY])
		return
	if(!controller.blackboard_key_exists(BB_KITTEN_TO_FEED))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_kitten, BB_KITTEN_TO_FEED, /mob/living/simple_animal/pet/cat/kitten)
		return

	controller.queue_behavior(/datum/ai_behavior/deliver_food_to_kitten, BB_KITTEN_TO_FEED, BB_FOOD_TO_DELIVER)

/datum/ai_behavior/find_and_set/valid_kitten

/datum/ai_behavior/find_and_set/valid_kitten/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/kitten = locate(locate_path) in oview(search_range, controller.pawn)
	//kitten already has food near it, go feed another hungry kitten

	if(isnull(kitten))
		return null

	var/list/nearby_food = typecache_filter_list(oview(2, kitten), controller.blackboard[BB_HUNTABLE_PREY])
	if(kitten.stat != DEAD && !length(nearby_food))
		return kitten
	return null

/datum/ai_behavior/deliver_food_to_kitten
/datum/ai_behavior/deliver_food_to_kitten
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 5 SECONDS

/datum/ai_behavior/deliver_food_to_kitten/setup(datum/ai_controller/controller, target_key, food_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/deliver_food_to_kitten/perform(seconds_per_tick, datum/ai_controller/controller, target_key, food_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key, food_key)
		return

	var/mob/living/living_pawn = controller.pawn
	var/atom/movable/food = controller.blackboard[food_key]

	if(isnull(food) || !(food in living_pawn))
		finish_action(controller, FALSE, target_key, food_key)
		return

	food.forceMove(get_turf(living_pawn))
	finish_action(controller, TRUE, target_key, food_key)

/datum/ai_behavior/deliver_food_to_kitten/finish_action(datum/ai_controller/controller, success, target_key, food_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(food_key)
