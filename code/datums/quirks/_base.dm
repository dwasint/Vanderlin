
GLOBAL_LIST_INIT(quirk_registry, list())
GLOBAL_LIST_EMPTY(quirk_points_by_type)

/proc/init_quirk_registry()
	GLOB.quirk_registry = list()
	GLOB.quirk_points_by_type = list(
		QUIRK_BOON = list(),
		QUIRK_VICE = list(),
		QUIRK_PECULIARITY = list()
	)

	for(var/quirk_type in subtypesof(/datum/quirk))
		var/datum/quirk/Q = quirk_type
		if(initial(Q.abstract_type) == quirk_type)
			continue

		var/category = initial(Q.quirk_category)
		GLOB.quirk_registry[initial(Q.name)] = quirk_type
		GLOB.quirk_points_by_type[category] += list(list(
			"name" = initial(Q.name),
			"type" = quirk_type,
			"desc" = initial(Q.desc),
			"value" = initial(Q.point_value)
		))

/datum/quirk
	abstract_type = /datum/quirk

	/// The quirk's name shown to players
	var/name = "Quirk"
	/// Description of what this quirk does
	var/desc = "A quirk."
	/// Category: QUIRK_BOON, QUIRK_VICE, or QUIRK_PECULIARITY
	var/quirk_category = QUIRK_PECULIARITY
	/// Point value (negative = costs points, positive = gives points)
	var/point_value = 0
	/// List of quirk types incompatible with this one
	var/list/incompatible_quirks = list()
	/// The mob this quirk is attached to
	var/mob/living/owner
	/// Can this be randomly selected?
	var/random_exempt = FALSE

/datum/quirk/New(mob/living/new_owner)
	. = ..()
	if(new_owner)
		owner = new_owner
		on_spawn()

/datum/quirk/Destroy()
	on_remove()
	owner = null
	return ..()

/// Called when the quirk is applied to a character
/datum/quirk/proc/on_spawn()
	return

/// Called when the quirk is removed
/datum/quirk/proc/on_remove()
	return

/// Called every life tick if implemented
/datum/quirk/proc/on_life(mob/living/user)
	return

/// Check if this quirk is compatible with a list of existing quirks
/datum/quirk/proc/is_compatible_with(list/datum/quirk/existing_quirks)
	for(var/datum/quirk/Q in existing_quirks)
		if(Q.type in incompatible_quirks)
			return FALSE
		if(type in Q.incompatible_quirks)
			return FALSE
	return TRUE

/mob/living/proc/add_quirk(quirk_type)
	return

/mob/living/carbon/human/add_quirk(quirk_type)
	if(!ispath(quirk_type, /datum/quirk))
		return FALSE

	// Check if already have this quirk
	for(var/datum/quirk/Q in quirks)
		if(Q.type == quirk_type)
			return FALSE

	var/datum/quirk/new_quirk = new quirk_type(src)
	quirks += new_quirk
	return TRUE

/mob/living/proc/remove_quirk(quirk_type)
	return

/mob/living/carbon/human/remove_quirk(quirk_type)
	for(var/datum/quirk/Q in quirks)
		if(Q.type == quirk_type)
			quirks -= Q
			qdel(Q)
			return TRUE
	return FALSE

/mob/living/proc/has_quirk(quirk_type)
	return

/mob/living/carbon/human/has_quirk(quirk_type)
	for(var/datum/quirk/Q in quirks)
		if(istype(Q, quirk_type))
			return TRUE
	return FALSE

/mob/living/proc/get_quirk(quirk_type)
	return

/mob/living/carbon/human/get_quirk(quirk_type)
	for(var/datum/quirk/Q in quirks)
		if(istype(Q, quirk_type))
			return Q
	return null

/mob/living/carbon/human/proc/clear_quirks()
	for(var/datum/quirk/Q in quirks)
		qdel(Q)
	quirks = list()

// Calculate total point balance from quirks
/mob/living/carbon/human/proc/get_quirk_balance()
	var/balance = STARTING_QUIRK_POINTS
	for(var/datum/quirk/Q in quirks)
		balance += Q.point_value
	return balance

// Count boons (negative point quirks)
/mob/living/carbon/human/proc/count_boons()
	var/count = 0
	for(var/datum/quirk/Q in quirks)
		if(Q.quirk_category == QUIRK_BOON)
			count++
	return count

// Validate quirk selection
/mob/living/carbon/human/proc/can_add_quirk(quirk_type)
	if(!ispath(quirk_type, /datum/quirk))
		return FALSE

	var/datum/quirk/temp_quirk = quirk_type

	// Check boon limit
	if(initial(temp_quirk.quirk_category) == QUIRK_BOON)
		if(count_boons() >= MAX_BOONS)
			return FALSE

	// Check point balance
	var/balance = get_quirk_balance()
	if(initial(temp_quirk.point_value) < 0) // Costs points
		if(balance + initial(temp_quirk.point_value) < 0)
			return FALSE

	// Check compatibility
	var/datum/quirk/test_quirk = new quirk_type()
	var/compatible = test_quirk.is_compatible_with(quirks)
	qdel(test_quirk)

	return compatible
