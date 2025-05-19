/datum/ai_planning_subtree/detect_vampire_or_race

/datum/ai_planning_subtree/detect_vampire_or_race/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/mob/living/simple_animal/pet/cat/cat_pawn = controller.pawn

	// Only run this check if the cat is being petted, via signal or other means
	if(QDELETED(cat_pawn) || cat_pawn.stat != CONSCIOUS)
		return

	// Set up a behavior to handle the reaction if needed
	controller.queue_behavior(/datum/ai_behavior/check_race_reaction)

/datum/ai_behavior/check_race_reaction
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/check_race_reaction/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	// This is called when someone interacts with the cat - logic implemented via attack_hand
	finish_action(controller, TRUE)
