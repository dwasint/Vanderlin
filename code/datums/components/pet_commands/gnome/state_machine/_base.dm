/datum/gnome_state
	var/name = "base_state"
	var/description = "Base state"

/// Called when entering this state
/datum/gnome_state/proc/enter_state(datum/ai_controller/controller)
	return

/// Called every tick while in this state
/datum/gnome_state/proc/process_state(datum/ai_controller/controller, delta_time)
	return GNOME_STATE_CONTINUE

/// Called when exiting this state
/datum/gnome_state/proc/exit_state(datum/ai_controller/controller)
	return

/// Check if we can transition to another state
/datum/gnome_state/proc/can_transition_to(datum/gnome_state/new_state, datum/ai_controller/controller)
	return TRUE


/datum/gnome_state_manager
	var/datum/gnome_state/current_state
	var/datum/gnome_state/queued_state
	var/list/available_states = list()

/datum/gnome_state_manager/New()
	init_states()

/datum/gnome_state_manager/proc/init_states()
	available_states = list(
		"idle" = new /datum/gnome_state/idle(),
		"transport" = new /datum/gnome_state/transport(),
		"farming" = new /datum/gnome_state/farming(),
		"alchemy" = new /datum/gnome_state/alchemy(),
		"splitter" = new /datum/gnome_state/splitter(),
		"return_home" = new /datum/gnome_state/return_home()
	)
	current_state = available_states["idle"]

/datum/gnome_state_manager/proc/process_machine(datum/ai_controller/controller, delta_time)
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

/datum/gnome_state_manager/proc/get_state_name()
	return current_state?.name || "unknown"
