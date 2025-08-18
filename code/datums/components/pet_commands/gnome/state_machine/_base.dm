/datum/gnome_state
	var/name = "base_state"
	var/description = "Base state"
	var/datum/gnome_state_manager/manager

/datum/gnome_state/New(datum/gnome_state_manager/_manager)
	. = ..()
	manager = _manager

// Called when entering this state
/datum/gnome_state/proc/enter_state(datum/ai_controller/controller)
	return

// Called every tick while in this state
/datum/gnome_state/proc/process_state(datum/ai_controller/controller, delta_time)
	return GNOME_STATE_CONTINUE

// Called when exiting this state
/datum/gnome_state/proc/exit_state(datum/ai_controller/controller)
	return

// Check if we can transition to another state
/datum/gnome_state/proc/can_transition_to(datum/gnome_state/new_state, datum/ai_controller/controller)
	return TRUE

/datum/gnome_state_manager
	var/datum/gnome_state/current_state
	var/datum/gnome_state/queued_state
	var/list/available_states = list()
	var/atom/last_movement_target = null

/datum/gnome_state_manager/New()
	init_states()

/datum/gnome_state_manager/proc/init_states()
	available_states = list(
		"idle" = new /datum/gnome_state/idle(src),
		"transport" = new /datum/gnome_state/transport(src),
		"farming" = new /datum/gnome_state/farming(src),
		"alchemy" = new /datum/gnome_state/alchemy(src),
		"splitter" = new /datum/gnome_state/splitter(src),
		"return_home" = new /datum/gnome_state/return_home(src)
	)
	current_state = available_states["idle"]

/datum/gnome_state_manager/proc/process_machine(datum/ai_controller/controller, delta_time)
	var/mob/living/pawn = controller.pawn

	// Check if we're still moving to a target
	if(last_movement_target)
		if(get_dist(pawn, last_movement_target) > 1)
			if(controller.ai_movement.moving_controllers[controller] != last_movement_target)
				controller.ai_movement.start_moving_towards(controller, last_movement_target)
			return // Still moving, don't process state machine
		else
			controller.set_movement_target(type, null)
			controller.ai_movement.stop_moving_towards(controller)
			last_movement_target = null // Reached target, clear it


	// Handle state transitions
	if(queued_state && current_state.can_transition_to(queued_state, controller))
		change_state(controller, queued_state)
		queued_state = null

	// Process current state
	var/result = current_state.process_state(controller, delta_time)
	switch(result)
		if(GNOME_STATE_COMPLETE, GNOME_STATE_FAILED)
			// Return to idle or handle completion
			if(current_state.name != "idle")
				queue_state("idle")

/datum/gnome_state_manager/proc/change_state(datum/ai_controller/controller, datum/gnome_state/new_state)
	if(current_state)
		current_state.exit_state(controller)
	current_state = new_state
	current_state.enter_state(controller)

/datum/gnome_state_manager/proc/queue_state(state_name)
	if(state_name in available_states)
		queued_state = available_states[state_name]
		return TRUE
	return FALSE

/datum/gnome_state_manager/proc/set_movement_target(datum/ai_controller/controller, atom/target)
	controller.set_movement_target(type, target)
	controller.ai_movement.start_moving_towards(controller, target)
	last_movement_target = target

/datum/gnome_state_manager/proc/get_state_name()
	return current_state?.name || "unknown"
