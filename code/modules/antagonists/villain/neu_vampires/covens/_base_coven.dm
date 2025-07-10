/datum/coven
	///Name of this Coven.
	var/name = "Coven name"
	///Text description of this Coven.
	var/desc = "Coven description"
	///Icon for this Coven as in Covens.dmi
	var/icon_state
	///If this Coven is unique to a certain Clan.
	var/clan_restricted = FALSE
	///The root type of the powers this Coven uses.
	var/power_type = /datum/coven_power
	///If this Coven can be selected at all, or has special handling.
	var/selectable = TRUE

	/* LEVELING SYSTEM */
	///What rank, or how many dots the caster has in this Coven.
	var/level = 1
	///Maximum level this coven can reach
	var/max_level = 5
	///Current experience points in this coven
	var/experience = 0
	///Experience needed to reach next level
	var/experience_needed = 100
	///Experience multiplier for each level (gets harder to level)
	var/experience_multiplier = 1.5

	/* BACKEND */
	///What rank of this Coven is currently being casted.
	var/level_casting = 1
	///The power that is currently in use.
	var/datum/coven_power/current_power
	///All Coven powers under this Coven that the owner knows. Derived from all_powers.
	var/list/datum/coven_power/known_powers = list()
	///The typepaths of possible powers for every rank in this Coven.
	var/all_powers = list()
	///The mob that owns and is using this Coven.
	var/mob/living/carbon/human/owner
	///If this Coven has been assigned before and post_gain effects have already been applied.
	var/post_gain_applied

	/* RESEARCH TREE INTEGRATION */
	///Associated research interface for this coven's power tree
	var/datum/coven_research_interface/research_interface
	///List of research nodes unlocked for this coven
	var/list/unlocked_research = list()
	///Current research points available to spend
	var/research_points = 0

//TODO: rework this and set_level to use proper loadouts instead of a default set every time
/datum/coven/New(level)
	all_powers = subtypesof(power_type)

	if (!level)
		return

	src.level = level
	for (var/i in 1 to level)
		var/type_to_create = all_powers[i]
		var/datum/coven_power/new_power = new type_to_create(src)
		known_powers += new_power
	current_power = known_powers[1]

/**
 * Modifies a Coven's level, updating its available powers
 * to conform to the new level. This proc will be removed when
 * power loadouts are implemented, but for now it's useful for dynamically
 * adding and removing powers.
 *
 * Arguments:
 * * level - the level to set the Coven as, powers included
 */
/datum/coven/proc/set_level(level)
	if (level == src.level)
		return

	var/list/datum/coven_power/new_known_powers = list()
	for (var/i in 1 to level)
		if (length(known_powers) >= level)
			new_known_powers.Add(known_powers[i])
		else
			var/adding_power_type = all_powers[i]
			var/datum/coven_power/new_power = new adding_power_type(src)
			new_known_powers.Add(new_power)
			new_power.post_gain()

	//delete orphaned powers
	var/list/datum/coven_power/leftover_powers = known_powers - new_known_powers
	if (length(leftover_powers))
		QDEL_LIST(leftover_powers)

	known_powers = new_known_powers
	src.level = level

/**
 * Assigns the Coven to a mob, setting its owner and applying
 * post_gain effects.
 *
 * Arguments:
 * * new_owner - the mob to assign the Coven to
 */
/datum/coven/proc/assign(mob/new_owner)
	if(new_owner == owner)
		return
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
	RegisterSignal(new_owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_qdel))
	owner = new_owner
	for (var/datum/coven_power/power in known_powers)
		power.set_owner(owner)

	if (!post_gain_applied)
		post_gain()
	post_gain_applied = TRUE

/**
 * Proc to handle potential hard dels.
 * Cleans up any remaining references to avoid circular reference memory leaks.
 * The GC will handle the rest.
 */
/datum/coven/proc/on_owner_qdel()
	SIGNAL_HANDLER
	owner = null
	current_power = null
	known_powers = null

/**
 * Returns a known Coven power in this Coven
 * searching by type.
 *
 * Arguments:
 * * power - the power type to search for
 */
/datum/coven/proc/get_power(power)
	if (!ispath(power))
		return
	for (var/datum/coven_power/found_power in known_powers)
		if (found_power.type == power)
			return found_power

/**
 * Applies effects specific to the Coven to
 * its owner. Also triggers post_gain effects of all
 * known (possessed) powers. Meant to be overridden
 * for modular code.
 */
/datum/coven/proc/post_gain()
	SHOULD_CALL_PARENT(TRUE)

	for (var/datum/coven_power/power in known_powers)
		power.post_gain()


/datum/coven/proc/initialize_research_tree()
	research_interface = new /datum/coven_research_interface(src)
	research_interface.initialize_coven_tree()

/datum/coven/proc/gain_experience(amount)
	experience += amount
	check_level_up()

	// Gain research points based on experience
	research_points += round(amount * 0.1) // 10% of experience becomes research points

	if(owner)
		to_chat(owner, "<span class='notice'>You gain [amount] experience in [name]. ([experience]/[experience_needed])</span>")
		if(research_points > 0)
			to_chat(owner, "<span class='boldnotice'>You have [research_points] research points to spend!</span>")

/datum/coven/proc/check_level_up()
	while(experience >= experience_needed && level < max_level)
		level_up()

/datum/coven/proc/level_up()
	experience -= experience_needed
	level++
	experience_needed = round(experience_needed * experience_multiplier)

	// Gain bonus research points on level up
	research_points += level * 5

	if(owner)
		to_chat(owner, "<span class='boldannounce'>Your [name] has reached level [level]!</span>")
		to_chat(owner, "<span class='notice'>You gain [level * 5] bonus research points!</span>")

	// Unlock new power tiers
	unlock_powers_for_level(level)

/datum/coven/proc/unlock_powers_for_level(new_level)
	for(var/power_type in all_powers)
		var/datum/coven_power/power = new power_type
		if(power.level <= new_level && !(power_type in known_powers))
			// Auto-unlock basic powers, but advanced ones require research
			if(power.level <= 2)
				learn_power(power_type)
			else
				// Make available for research
				if(research_interface)
					research_interface.unlock_research_node(power_type)
		qdel(power)

/datum/coven/proc/learn_power(power_type)
	if(power_type in known_powers)
		return FALSE

	var/datum/coven_power/power = new power_type
	power.owner = owner
	power.discipline = src
	known_powers[power_type] = power

	if(owner)
		to_chat(owner, "<span class='boldnotice'>You have learned [power.name]!</span>")

	return TRUE

/datum/coven/proc/can_research(research_type)
	if(!research_interface)
		return FALSE

	var/datum/coven_research_node/node = research_interface.get_research_node(research_type)
	if(!node)
		return FALSE

	// Check if prerequisites are met
	for(var/prereq in node.prerequisites)
		if(!(prereq in unlocked_research))
			return FALSE

	// Check if we have enough research points
	if(research_points < node.research_cost)
		return FALSE

	return TRUE

/datum/coven/proc/research_power(research_type)
	if(!can_research(research_type))
		return FALSE

	var/datum/coven_research_node/node = research_interface.get_research_node(research_type)
	research_points -= node.research_cost
	unlocked_research += research_type

	// Learn the associated power
	if(node.unlocks_power)
		learn_power(node.unlocks_power)

	// Apply any special effects
	if(node.special_effect)
		apply_research_effect(node.special_effect)

	if(owner)
		to_chat(owner, "<span class='boldnotice'>You have researched [node.name]!</span>")

	return TRUE

/datum/coven/proc/apply_research_effect(effect_type)
	switch(effect_type)
		if("reduce_vitae_cost")
			// Reduce vitae costs of all powers by 10%
			for(var/power_type in known_powers)
				var/datum/coven_power/power = known_powers[power_type]
				power.vitae_cost = max(1, round(power.vitae_cost * 0.9))
		if("increase_range")
			// Increase range of all powers by 1
			for(var/power_type in known_powers)
				var/datum/coven_power/power = known_powers[power_type]
				power.range += 1
		if("reduce_cooldown")
			// Reduce cooldowns by 20%
			for(var/power_type in known_powers)
				var/datum/coven_power/power = known_powers[power_type]
				power.cooldown_length = max(0, round(power.cooldown_length * 0.8))

