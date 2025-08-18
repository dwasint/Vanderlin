
/datum/gnome_state/return_home
	name = "return_home"
	description = "Returning to home position"

/datum/gnome_state/return_home/process_state(datum/ai_controller/controller, delta_time)
	var/mob/living/pawn = controller.pawn
	var/turf/home_turf = controller.blackboard[BB_GNOME_HOME_TURF]

	if(!home_turf)
		return GNOME_STATE_FAILED

	if(get_turf(pawn) == home_turf)
		return GNOME_STATE_COMPLETE

	manager.set_movement_target(controller, home_turf)
	return GNOME_STATE_CONTINUE
