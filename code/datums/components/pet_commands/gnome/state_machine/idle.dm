
/datum/gnome_state/idle
	name = "idle"
	description = "Waiting for commands or returning home"

/datum/gnome_state/idle/process_state(datum/ai_controller/controller, delta_time)
	var/mob/living/pawn = controller.pawn
	var/turf/home_turf = controller.blackboard[BB_GNOME_HOME_TURF]

	// Check for active pet commands first
	var/datum/pet_command/active_command = controller.blackboard[BB_ACTIVE_PET_COMMAND]
	if(active_command)
		active_command.execute_action(controller)
		return GNOME_STATE_CONTINUE

	// Return home if away
	if(home_turf && get_turf(pawn) != home_turf)
		var/datum/gnome_state_manager/manager = controller.blackboard[BB_GNOME_STATE_MANAGER]
		manager.queue_state("return_home")
		return GNOME_STATE_CONTINUE

	// Random walk behavior when idle at home
	return GNOME_STATE_CONTINUE
