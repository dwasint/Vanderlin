/datum/element/ai_aggro_system
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2

	/// Default threat threshold before a mob is considered hostile
	var/default_threat_threshold = 10
	/// Default range at which mobs detect and add threats
	var/default_aggro_range = 9
	/// Default range at which mobs maintain aggro before dropping target
	var/default_maintain_range = 12
	/// Default decay rate per second
	var/default_decay_rate = 2
	/// Decay timer interval in seconds
	var/decay_timer_interval = 1

/datum/element/ai_aggro_system/Attach(datum/target, threat_threshold, aggro_range, maintain_range, decay_rate)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/living_mob = target
	if(!living_mob.ai_controller)
		return ELEMENT_INCOMPATIBLE

	// Initialize the aggro table
	living_mob.ai_controller.set_blackboard_key(BB_MOB_AGGRO_TABLE, list())

	// Set configurable parameters
	living_mob.ai_controller.set_blackboard_key(BB_THREAT_THRESHOLD, threat_threshold || default_threat_threshold)
	living_mob.ai_controller.set_blackboard_key(BB_AGGRO_RANGE, aggro_range || default_aggro_range)
	living_mob.ai_controller.set_blackboard_key(BB_AGGRO_MAINTAIN_RANGE, maintain_range || default_maintain_range)

	// Set up decay timer
	var/decay = decay_rate || default_decay_rate
	var/timer_id = addtimer(CALLBACK(src, PROC_REF(decay_aggro), living_mob, decay), decay_timer_interval SECONDS, TIMER_STAGGERED | TIMER_LOOP)
	living_mob.ai_controller.set_blackboard_key(BB_AGGRO_DECAY_TIMER, timer_id)

	// Register signals
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_changed))
	RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(on_death))

/datum/element/ai_aggro_system/Detach(datum/source, ...)
	. = ..()
	var/mob/living/living_mob = source
	if(!living_mob.ai_controller)
		return

	// Clean up timer
	var/timer_id = living_mob.ai_controller.blackboard[BB_AGGRO_DECAY_TIMER]
	if(timer_id)
		deltimer(timer_id)

	// Unregister signals
	UnregisterSignal(source, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_LIVING_HEALTH_UPDATE,
		COMSIG_MOB_DEATH
	))

/// Adds threat to an attacker based on damage dealt
/datum/element/ai_aggro_system/proc/on_attacked(mob/victim, atom/attacker, damage)
	SIGNAL_HANDLER

	if(!victim.ai_controller)
		return

	if(!ismob(attacker))
		return

	// Base threat from being attacked
	var/threat_to_add = 5

	// Add additional threat based on damage if provided
	if(damage)
		threat_to_add += damage * 0.5

	add_threat(victim, attacker, threat_to_add)

/// Updates threat table when health changes (for healing, etc.)
/datum/element/ai_aggro_system/proc/on_health_changed(mob/living/source, health_diff)
	SIGNAL_HANDLER

	if(!source.ai_controller)
		return

	// If health increased (healing), find who did it
	if(health_diff > 0)
		var/mob/healer = source.ai_controller.blackboard[BB_HEALING_SOURCE]
		if(healer && ismob(healer))
			// Healing reduces threat (negative threat modifier)
			add_threat(source, healer, -health_diff * 0.3)

/// Clears the aggro table when the mob dies
/datum/element/ai_aggro_system/proc/on_death(mob/living/source)
	SIGNAL_HANDLER

	if(!source.ai_controller)
		return

	// Clear aggro table on death
	source.ai_controller.set_blackboard_key(BB_MOB_AGGRO_TABLE, list())
	source.ai_controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)

/// Adds or modifies threat level for a specific mob
/datum/element/ai_aggro_system/proc/add_threat(mob/victim, mob/attacker, amount)
	if(!victim?.ai_controller || !attacker)
		return

	var/list/aggro_table = victim.ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(!aggro_table)
		aggro_table = list()

	// Add or update threat level
	if(aggro_table[attacker])
		aggro_table[attacker] += amount
	else
		aggro_table[attacker] = amount

	// Ensure threat level isn't negative
	if(aggro_table[attacker] < 0)
		aggro_table[attacker] = 0

	// Update the aggro table
	victim.ai_controller.set_blackboard_key(BB_MOB_AGGRO_TABLE, aggro_table)

	// Update highest threat mob
	update_highest_threat(victim)

/// Periodically decays threat levels
/datum/element/ai_aggro_system/proc/decay_aggro(mob/living/source, decay_amount)
	if(!source?.ai_controller)
		return

	var/list/aggro_table = source.ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(!aggro_table || !length(aggro_table))
		return

	var/list/to_remove = list()

	// Decay all threat values
	for(var/mob/threat_mob as anything in aggro_table)
		aggro_table[threat_mob] -= decay_amount

		// If threat drops below 0, mark for removal
		if(aggro_table[threat_mob] <= 0)
			to_remove += threat_mob

	// Remove any mobs with 0 or negative threat
	for(var/mob/threat_mob as anything in to_remove)
		aggro_table -= threat_mob

	// Update the aggro table
	source.ai_controller.set_blackboard_key(BB_MOB_AGGRO_TABLE, aggro_table)

	// Update highest threat mob
	update_highest_threat(source)

/// Updates who the highest threat mob is
/datum/element/ai_aggro_system/proc/update_highest_threat(mob/living/source)
	if(!source?.ai_controller)
		return

	var/list/aggro_table = source.ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(!aggro_table || !length(aggro_table))
		source.ai_controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
		return

	var/highest_threat = 0
	var/mob/highest_threat_mob = null

	// Find the mob with the highest threat
	for(var/mob/threat_mob as anything in aggro_table)
		if(aggro_table[threat_mob] > highest_threat)
			highest_threat = aggro_table[threat_mob]
			highest_threat_mob = threat_mob

	// Update highest threat mob if it meets threshold
	var/threat_threshold = source.ai_controller.blackboard[BB_THREAT_THRESHOLD] || default_threat_threshold
	if(highest_threat >= threat_threshold)
		source.ai_controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, highest_threat_mob)
	else
		source.ai_controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
