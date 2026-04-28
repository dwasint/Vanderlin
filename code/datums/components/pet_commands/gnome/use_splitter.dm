
/datum/pet_command/gnome/use_splitter
	command_name = "Use Splitter"
	command_desc = "Grab items from waypoint A and process them in the splitter"
	radial_icon_state = "split"
	speech_commands = list("split", "process", "use splitter", "extract")
	requires_pointing = TRUE
	pointed_reaction = "and focuses on the splitter"

/datum/pet_command/gnome/use_splitter/look_for_target(mob/living/pointing_friend, atom/pointed_atom)
	if(!istype(pointed_atom, /obj/machinery/essence/splitter) && !istype(pointed_atom, /obj/machinery/essence/extractor))
		return FALSE
	return ..()

/datum/pet_command/gnome/use_splitter/execute_action(datum/ai_controller/controller)
	var/turf/waypoint_a = controller.blackboard[BB_GNOME_WAYPOINT_A]
	var/atom/target = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(!waypoint_a)
		var/mob/living/pawn = controller.pawn
		pawn.visible_message(span_warning("[pawn] looks confusedly - no source waypoint set!"))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return
	if(!target)
		return
	if(istype(target, /obj/machinery/essence/extractor))
		controller.set_blackboard_key(BB_GNOME_EXTRACTOR_MODE, TRUE)
		controller.set_blackboard_key(BB_GNOME_TARGET_EXTRACTOR, target)
	else
		controller.set_blackboard_key(BB_GNOME_SPLITTER_MODE, TRUE)
		controller.set_blackboard_key(BB_GNOME_TARGET_SPLITTER, target)
	controller.set_blackboard_key(BB_GNOME_SPLITTER_SOURCE, waypoint_a)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/gnome/stop_splitter/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_GNOME_SPLITTER_MODE, FALSE)
	controller.set_blackboard_key(BB_GNOME_EXTRACTOR_MODE, FALSE)
	controller.clear_blackboard_key(BB_GNOME_TARGET_SPLITTER)
	controller.clear_blackboard_key(BB_GNOME_TARGET_EXTRACTOR)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	var/mob/living/pawn = controller.pawn
	pawn.visible_message(span_notice("[pawn] stops focusing on the machine."))

/datum/pet_command/gnome/stop_splitter
	command_name = "Stop Splitter"
	command_desc = "Stop using the splitter"
	radial_icon_state = "split-stop"
	speech_commands = list("stop splitting", "stop splitter", "enough")

/datum/pet_command/gnome/stop_splitter/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_GNOME_SPLITTER_MODE, FALSE)
	controller.clear_blackboard_key(BB_GNOME_TARGET_SPLITTER)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

	var/mob/living/pawn = controller.pawn
	pawn.visible_message(span_notice("[pawn] stops focusing on the splitter."))
