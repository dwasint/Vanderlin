/datum/ai_controller/saiga
	movement_cooldown = 0.7 SECONDS
	blackboard = list(
		BB_TARGET_HELD_ITEM = /obj/item/reagent_containers/food/snacks/produce/grain,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items/not_holding_item(),
		BB_PET_TARGETING_DATUM = new /datum/targetting_datum/basic/not_friends(),
	)

	ai_movement = /datum/ai_movement/hybrid_pathing
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
	)


/datum/ai_controller/saiga_kid
	blackboard = list(
		BB_TARGET_HELD_ITEM = /obj/item/reagent_containers/food/snacks/produce/grain,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items/not_holding_item(),
		BB_PET_TARGETING_DATUM = new /datum/targetting_datum/basic/not_friends(),
	)

	ai_movement = /datum/ai_movement/hybrid_pathing
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)
