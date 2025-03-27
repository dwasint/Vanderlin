/datum/ai_behavior/equip_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/equip_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/equip_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/item/target = controller.blackboard[target_key]
	var/mob/living/carbon/human/pawn = controller.pawn

	if(pawn.equip_item(target))
		finish_action(controller, TRUE)
		return
	finish_action(controller, FALSE)
