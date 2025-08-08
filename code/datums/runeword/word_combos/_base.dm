GLOBAL_LIST_INIT(all_runewords, initialize_runewords())

/proc/initialize_runewords()
	var/list/runewords = list()
	for(var/datum/runeword/runeword as anything in subtypesof(/datum/runeword))
		if(is_abstract(runeword))
			continue
		runewords |= runeword
		runewords[runeword] = new runeword

	return runewords


/datum/runeword
	var/name = ""
	var/list/runes = list() // Required rune sequence
	var/sockets_required = 2
	var/list/allowed_items = list() // Item types that can hold this runeword
	var/list/stat_bonuses = list() // Direct stat modifications
	var/list/combat_effects = list() // Combat-related effects
	var/list/spell_actions = list() // Spell actions to grant
	var/obj/item/attached_item = null // The item this runeword is on

/datum/runeword/New(obj/item/item)
	..()
	if(item)
		attached_item = item
		register_signals()

	var/list/new_combat = list()
	for(var/datum/rune_effect/effect as anything in combat_effects)
		new_combat |= new effect(combat_effects[effect])

	combat_effects = new_combat

/datum/runeword/Destroy()
	clear_signals()
	attached_item = null
	return ..()

/datum/runeword/proc/register_signals()
	if(!attached_item)
		return

	// Register for attack signals to handle damage bonuses and effects
	RegisterSignal(attached_item, COMSIG_ITEM_AFTERATTACK, PROC_REF(handle_afterattack))

/datum/runeword/proc/clear_signals()
	if(!attached_item)
		return

	UnregisterSignal(attached_item, COMSIG_ITEM_AFTERATTACK)

/datum/runeword/proc/handle_afterattack(obj/item/source, atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!proximity_flag || !isliving(target) || !isliving(user))
		return

	var/mob/living/living_target = target

	// Apply all combat effects through the elemental system
	apply_combat_effects(living_target, user, 0)

/datum/runeword/proc/apply_combat_effects(mob/living/target, mob/living/user, damage_dealt)
	for(var/datum/rune_effect/effect as anything in combat_effects)
		effect.apply_combat_effect(target, user, damage_dealt)


/obj/item
	var/sockets = 0
	var/max_sockets = 0
	var/list/socketed_runes = list()
	var/datum/runeword/active_runeword = null
	var/runeword_name = ""

	var/cold_res = 0
	var/fire_res = 0
	var/lightning_res = 0


	var/max_cold_res = 0
	var/max_fire_res = 0
	var/max_lightning_res = 0

/obj/item/proc/return_resistance(resistance_type = COLD_DAMAGE)
	switch(resistance_type)
		if(COLD_DAMAGE)
			return cold_res
		if(FIRE_DAMAGE)
			return fire_res
		if(LIGHTNING_DAMAGE)
			return lightning_res

/obj/item/proc/return_max_resistance_modifier(resistance_type = COLD_DAMAGE)
	switch(resistance_type)
		if(COLD_DAMAGE)
			return max_cold_res
		if(FIRE_DAMAGE)
			return max_fire_res
		if(LIGHTNING_DAMAGE)
			return max_lightning_res

/obj/item/proc/add_socket()
	if(sockets >= max_sockets)
		return FALSE
	sockets++
	return TRUE

/obj/item/proc/can_socket_rune(obj/item/rune/R)
	if(!R || !istype(R, /obj/item/rune))
		return FALSE
	if(socketed_runes.len >= sockets)
		return FALSE
	return TRUE

/obj/item/proc/socket_rune(obj/item/rune/R, mob/user)
	if(!can_socket_rune(R))
		to_chat(user, "<span class='warning'>This item cannot accept another rune!</span>")
		return FALSE

	socketed_runes += R.rune_type
	qdel(R)

	to_chat(user, "<span class='notice'>You socket the [R.name] into [src].</span>")

	// Check if we've completed a runeword
	check_runeword_completion(user)

	return TRUE

/obj/item/proc/check_runeword_completion(mob/user)
	initialize_runewords()

	for(var/runeword_type in GLOB.all_runewords)
		var/datum/runeword/template = GLOB.all_runewords[runeword_type]

		if(template.sockets_required != socketed_runes.len)
			continue

		// Check if our socketed runes match the runeword sequence
		var/match = TRUE
		for(var/i = 1 to template.runes.len)
			if(socketed_runes[i] != template.runes[i])
				match = FALSE
				break

		if(!match)
			continue

		// Check if this item type is allowed for this runeword
		var/type_allowed = FALSE
		for(var/allowed_type in template.allowed_items)
			if(istype(src, allowed_type))
				type_allowed = TRUE
				break

		if(!type_allowed)
			continue

		// We have a match! Apply the runeword
		apply_runeword(runeword_type, user)
		return TRUE

	return FALSE

/obj/item/proc/apply_runeword(runeword_type, mob/user)
	// Create the runeword instance and attach it to this item
	active_runeword = new runeword_type(src)
	runeword_name = active_runeword.name

	name = "[active_runeword.name] [name]"

	// Apply stat bonuses (non-resistance stats)
	apply_runeword_stats(active_runeword)

	// Apply resistance effects to the item
	apply_runeword_resistances(active_runeword)

	// Add spell actions
	apply_runeword_spells(active_runeword)

	to_chat(user, "<span class='boldnotice'>[src] transforms into the [active_runeword.name] runeword!</span>")

/obj/item/proc/apply_runeword_resistances(datum/runeword/RW)
	for(var/datum/rune_effect/effect as anything in RW.combat_effects)
		if(istype(effect, /datum/rune_effect/resistance))
			var/datum/rune_effect/resistance/res_effect = effect
			res_effect.apply_to_item(src)

/obj/item/proc/apply_runeword_stats(datum/runeword/RW)
	for(var/stat in RW.stat_bonuses)
		var/value = RW.stat_bonuses[stat]

		switch(stat)
			if("force_bonus")
				if(istype(src, /obj/item/weapon))
					var/obj/item/weapon/W = src
					W.force += value

			if("throwforce_bonus")
				throwforce += value

			if("max_integrity_bonus")
				max_integrity += value
				obj_integrity = min(obj_integrity + value, max_integrity)

/obj/item/proc/apply_runeword_spells(datum/runeword/RW)
	for(var/spell_type in RW.spell_actions)
		add_item_action(spell_type)

/obj/item/weapon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rune))
		var/obj/item/rune/R = I
		socket_rune(R, user)
		return
	return ..()

/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rune))
		var/obj/item/rune/R = I
		socket_rune(R, user)
		return
	return ..()

/obj/item/examine(mob/user)
	. = ..()
	if(sockets > 0)
		. += "<span class='notice'>This item has [sockets] socket[sockets > 1 ? "s" : ""].</span>"
		if(socketed_runes.len > 0)
			. += "<span class='notice'>Socketed runes: [english_list(socketed_runes)]</span>"
		if(active_runeword)
			. += "<span class='boldnotice'>This item contains the [active_runeword.name] runeword!</span>"

/obj/item/Destroy()
	if(active_runeword)
		qdel(active_runeword)
		active_runeword = null
	return ..()
