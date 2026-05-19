/datum/preferences/proc/open_loadout_shop(mob/mob)
	var/datum/tgui_triumph_shop/ui = new /datum/tgui_triumph_shop(mob.client)
	ui.ui_interact(mob)

/datum/preferences/proc/load_triumph_shop_character_data(savefile/S)
	if(!S)
		return
	S["equipped_loadout"] >> equipped_loadout
	if(!islist(equipped_loadout))
		equipped_loadout = list()
	validate_loadouts()

/datum/preferences/proc/validate_loadouts()
	var/list/clean_owned = list()
	for(var/path_str in owned_loadout_items)
		var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
		if(!item)
			continue
		// Achievement check: item must still be unlocked.
		if(!item.is_unlocked_for(parent))
			continue
		// Patreon check: lapsed subs lose patreon-locked items.
		if((item.loadout_flags & LOADOUT_FLAG_PATREON_LOCKED) && !parent?.patreon?.is_donator())
			continue
		clean_owned += path_str
	owned_loadout_items = clean_owned

	var/list/clean_equipped = list()
	for(var/path_str in equipped_loadout)
		if(!(path_str in owned_loadout_items))
			continue
		var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
		// NO_EQUIP items must not occupy a loadout slot under any circumstances.
		if(item && (item.loadout_flags & LOADOUT_FLAG_NO_EQUIP))
			continue
		clean_equipped += path_str
	if(length(clean_equipped) > 3)
		clean_equipped = clean_equipped.Copy(1, 4)
	equipped_loadout = clean_equipped
	return TRUE

/proc/apply_loadouts(mob/living/carbon/human/character, client/player)
	if(!player?.prefs)
		return
	var/slot = 1
	for(var/path_str in player.prefs.equipped_loadout)
		if(slot > 3)
			break
		var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
		if(!item)
			continue
		var/atom/item_path = item.item_path
		character.mind.special_items[initial(item_path.name)] = item.item_path
		slot++
	for(var/path_str in player.prefs.single_round_loadout)
		if(slot > 3)
			break
		if(path_str in player.prefs.equipped_loadout)
			continue // already applied above
		var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
		if(!item)
			continue
		var/atom/item_path = item.item_path
		character.mind.special_items[initial(item_path.name)] = item.item_path
		slot++
	player.prefs.single_round_loadout = list()
	player.prefs.save_preferences()

/datum/tgui_triumph_shop
	var/client/owner

/datum/tgui_triumph_shop/New(client/C)
	owner = C

/datum/tgui_triumph_shop/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TriumphShop")
		ui.open()

/datum/tgui_triumph_shop/ui_state(mob/user, datum/tgui/ui)
	return GLOB.always_state

/datum/tgui_triumph_shop/ui_data(mob/user)
	var/list/data = list()
	var/total_weight = 0
	for(var/tt in GLOB.special_traits)
		var/datum/special_trait/trait = SPECIAL_TRAIT(tt)
		total_weight += trait.weight

	data["triumph_balance"] = get_triumph_amount(owner.ckey)
	data["cost_random_special"] = TRIUMPH_COST_RANDOM_SPECIAL
	data["cost_specific_special"] = TRIUMPH_COST_SPECIFIC_SPECIAL

	// Pending special for next spawn
	var/pending = owner.prefs.next_special_trait
	data["pending_special"] = pending ? "[pending]" : null

	// Loadout categories
	var/list/categories = list()
	for(var/path in GLOB.loadout_items)
		var/datum/loadout_item/item = GLOB.loadout_items[path]
		var/cat = item.ui_category
		if(!(cat in categories))
			categories[cat] = list()
		var/path_str = "[path]"
		categories[cat] += list(list(
			"path" = path_str,
			"name" = item.name,
			"description" = item.description,
			"cost_single" = item.triumph_cost_single,
			"cost_permanent" = item.triumph_cost_permanent,
			"free" = (!item.triumph_cost_single && !item.triumph_cost_permanent),
			"owned" = (path_str in owner.prefs.owned_loadout_items),
			"equipped" = (path_str in owner.prefs.equipped_loadout),
			"rented" = (path_str in owner.prefs.single_round_loadout),
			"can_afford_single" = item.can_afford_single(owner),
			"can_afford_perm" = item.can_afford_permanent(owner),
			"award_locked" = !!(item.required_award && !item.is_unlocked_for(owner)),
			"ui_icon" = item.ui_icon,
			"ui_icon_state" = item.ui_icon_state,
			"no_rent" = !!(item.loadout_flags & LOADOUT_FLAG_NO_RENT),
			"no_equip" = !!(item.loadout_flags & LOADOUT_FLAG_NO_EQUIP),
			"patreon_locked" = !!(item.loadout_flags & LOADOUT_FLAG_PATREON_LOCKED),
			"category" = cat
		))
	data["categories"] = categories

	// Equipped slots (ordered, always 3 entries)
	var/list/slots = list()
	for(var/i in 1 to 3)
		var/path_str = (length(owner.prefs.equipped_loadout) >= i) \
			? owner.prefs.equipped_loadout[i] : null
		if(path_str)
			var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
			slots += list(list(
				"path" = path_str,
				"name" = item ? item.name : "Unknown",
				"permanent" = TRUE
			))
		else
			// Check single-round rentals to fill display
			var/rent_idx = i - length(owner.prefs.equipped_loadout)
			if(rent_idx >= 1 && rent_idx <= length(owner.prefs.single_round_loadout))
				var/rpath = owner.prefs.single_round_loadout[rent_idx]
				var/datum/loadout_item/ritem = GLOB.loadout_items[text2path(rpath)]
				slots += list(list(
					"path" = rpath,
					"name" = ritem ? "[ritem.name] (this round)" : "Rental",
					"permanent" = FALSE
				))
			else
				slots += list(list("path" = null, "name" = "Empty", "permanent" = FALSE))
	data["equipped_slots"] = slots

	var/mob/living/carbon/human/preview = owner.mob
	var/list/specials_list = list()
	for(var/trait_type in GLOB.special_traits)
		var/datum/special_trait/trait = SPECIAL_TRAIT(trait_type)
		var/expected_rolls = (trait.weight > 0) ? (total_weight / trait.weight) : 999
		var/patreon_modifier = user.client.is_donator() ? 0.5 : 1
		var/computed_cost = FLOOR(expected_rolls * TRIUMPH_COST_RANDOM_SPECIAL * trait.cost_modifier * patreon_modifier, 1)
		var/eligible = TRUE
		if(istype(preview, /mob/living/carbon/human))
			eligible = !!charactet_eligible_for_trait(preview, owner, trait_type)
		specials_list += list(list(
			"path" = "[trait_type]",
			"name" = trait.name,
			"greet_text" = trait.greet_text,
			"req_text" = trait.req_text,
			"weight" = trait.weight,
			"total_weight" = total_weight,
			"eligible" = eligible,
			"cost_random" = TRIUMPH_COST_RANDOM_SPECIAL,
			"cost_specific" = computed_cost,
			"is_pending" = (pending == trait_type)
		))
	data["specials"] = specials_list

	return data

/datum/tgui_triumph_shop/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("buy_permanent")
			return handle_buy_permanent(params["path"])
		if("buy_single")
			return handle_buy_single(params["path"])
		if("equip_item")
			return handle_equip(params["path"])
		if("unequip_item")
			return handle_unequip(params["path"])
		if("buy_random_special")
			return handle_random_special()
		if("buy_specific_special")
			return handle_specific_special(params["path"])
		if("clear_pending_special")
			return handle_clear_pending_special()
	return FALSE

/datum/tgui_triumph_shop/proc/handle_buy_permanent(path_str)
	var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
	if(!item)
		return FALSE
	if(path_str in owner.prefs.owned_loadout_items)
		return FALSE
	if(!item.is_unlocked_for(owner))
		if(item.required_award)
			to_chat(owner.mob, span_warning("You haven't unlocked the achievement required for [item.name]."))
		else if(item.loadout_flags & LOADOUT_FLAG_PATREON_LOCKED)
			to_chat(owner.mob, span_warning("[item.name] requires an active Patreon subscription."))
		return FALSE
	if(item.triumph_cost_permanent > 0)
		var/balance = get_triumph_amount(owner.ckey)
		if(balance < item.triumph_cost_permanent)
			to_chat(owner.mob, span_warning("You need [item.triumph_cost_permanent] triumphs to permanently unlock [item.name]. You have [balance]."))
			return FALSE
		adjust_triumphs(owner, -item.triumph_cost_permanent, TRUE, "Triumph Shop: permanent unlock [item.name]", FALSE, TRUE)
	owner.prefs.owned_loadout_items += path_str
	owner.prefs.save_preferences()
	log_game("TRIUMPH SHOP: [owner.ckey] permanently unlocked [path_str] for [item.triumph_cost_permanent] triumphs.")
	to_chat(owner.mob, span_notice("Permanently unlocked [item.name]!"))
	return TRUE

/datum/tgui_triumph_shop/proc/handle_buy_single(path_str)
	var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
	if(!item)
		return FALSE
	if(item.loadout_flags & LOADOUT_FLAG_NO_RENT)
		to_chat(owner.mob, span_warning("[item.name] cannot be rented — it must be permanently unlocked."))
		return FALSE
	if(item.loadout_flags & LOADOUT_FLAG_NO_EQUIP)
		to_chat(owner.mob, span_warning("[item.name] cannot be equipped as a loadout item."))
		return FALSE
	if(path_str in owner.prefs.owned_loadout_items)
		return FALSE
	if(path_str in owner.prefs.single_round_loadout)
		return FALSE
	if(!item.is_unlocked_for(owner))
		to_chat(owner.mob, span_warning("You don't meet the requirements for [item.name]."))
		return FALSE
	var/used = length(owner.prefs.equipped_loadout) + length(owner.prefs.single_round_loadout)
	if(used >= 3)
		to_chat(owner.mob, span_warning("All 3 loadout slots are in use."))
		return FALSE
	if(item.triumph_cost_single > 0)
		var/balance = get_triumph_amount(owner.ckey)
		if(balance < item.triumph_cost_single)
			to_chat(owner.mob, span_warning("You need [item.triumph_cost_single] triumphs to rent [item.name]. You have [balance]."))
			return FALSE
		adjust_triumphs(owner, -item.triumph_cost_single, TRUE, "Triumph Shop: single-round rent [item.name]", FALSE, TRUE)
	owner.prefs.single_round_loadout += path_str
	owner.prefs.save_preferences()
	log_game("TRIUMPH SHOP: [owner.ckey] rented [path_str] for one round ([item.triumph_cost_single] triumphs).")
	to_chat(owner.mob, span_notice("Rented [item.name] for this round."))
	return TRUE

/datum/tgui_triumph_shop/proc/handle_equip(path_str)
	if(!(path_str in owner.prefs.owned_loadout_items))
		return FALSE
	if(path_str in owner.prefs.equipped_loadout)
		return FALSE
	var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
	if(item && (item.loadout_flags & LOADOUT_FLAG_NO_EQUIP))
		to_chat(owner.mob, span_warning("[item.name] cannot be equipped as a loadout slot item."))
		return FALSE
	var/used = length(owner.prefs.equipped_loadout) + length(owner.prefs.single_round_loadout)
	if(used >= 3)
		to_chat(owner.mob, span_warning("All 3 loadout slots are in use."))
		return FALSE
	owner.prefs.equipped_loadout += path_str
	owner.prefs.save_preferences()
	return TRUE

/datum/tgui_triumph_shop/proc/handle_unequip(path_str)
	if(path_str in owner.prefs.equipped_loadout)
		owner.prefs.equipped_loadout -= path_str
		owner.prefs.save_preferences()
		return TRUE
	if(path_str in owner.prefs.single_round_loadout)
		owner.prefs.single_round_loadout -= path_str
		owner.prefs.save_preferences()
		// Refund the single-round cost
		var/datum/loadout_item/item = GLOB.loadout_items[text2path(path_str)]
		if(item?.triumph_cost_single > 0)
			adjust_triumphs(owner, item.triumph_cost_single, TRUE, "Triumph Shop: refund rent [item.name]", FALSE, TRUE)
		return TRUE
	return FALSE

/datum/tgui_triumph_shop/proc/handle_random_special()
	if(owner.prefs.next_special_trait)
		to_chat(owner.mob, span_warning("You already have a special trait queued. Clear it first."))
		return FALSE
	var/balance = get_triumph_amount(owner.ckey)
	if(balance < TRIUMPH_COST_RANDOM_SPECIAL)
		to_chat(owner.mob, span_warning("You need [TRIUMPH_COST_RANDOM_SPECIAL] triumphs to roll a random special. You have [balance]."))
		return FALSE
	// roll_random_special uses weight-based pickweight across ALL specials
	// (not filtered by character eligibility, this is intentional for random rolls)
	var/rolled = roll_random_special(owner)
	if(!rolled)
		to_chat(owner.mob, span_warning("No specials available to roll."))
		return FALSE
	adjust_triumphs(owner, -TRIUMPH_COST_RANDOM_SPECIAL, TRUE, "Triumph Shop: random special roll", FALSE, TRUE)
	owner.prefs.next_special_trait = rolled
	owner.prefs.save_preferences()
	var/datum/special_trait/trait = SPECIAL_TRAIT(rolled)
	log_game("TRIUMPH SHOP: [owner.ckey] rolled random special [rolled] ([trait?.name]) for [TRIUMPH_COST_RANDOM_SPECIAL] triumphs.")
	to_chat(owner.mob, span_notice("You rolled: <b>[trait?.name]</b>! Applies on your next spawn."))
	return TRUE

/datum/tgui_triumph_shop/proc/handle_specific_special(path_str)
	if(owner.prefs.next_special_trait)
		to_chat(owner.mob, span_warning("You already have a special trait queued. Clear it first."))
		return FALSE
	var/trait_type = text2path(path_str)
	if(!trait_type || !(trait_type in GLOB.special_traits))
		return FALSE
	var/mob/living/carbon/human/preview = owner.mob
	if(istype(preview, /mob/living/carbon/human))
		if(!charactet_eligible_for_trait(preview, owner, trait_type))
			to_chat(owner.mob, span_warning("Your character does not meet the requirements for that trait."))
			return FALSE
	//never trust client-sent cost I don't want some fuck ass -1000000 cost
	var/total_weight = 0
	for(var/tw in GLOB.special_traits)
		var/datum/special_trait/special = SPECIAL_TRAIT(tw)
		total_weight += special.weight
	var/datum/special_trait/trait = SPECIAL_TRAIT(trait_type)
	var/expected_rolls = (trait.weight > 0) ? (total_weight / trait.weight) : 999
	var/patreon_modifier = owner.is_donator() ? 0.5 : 1
	var/cost = FLOOR(expected_rolls * TRIUMPH_COST_RANDOM_SPECIAL * trait.cost_modifier * patreon_modifier, 1)
	var/balance = get_triumph_amount(owner.ckey)
	if(balance < cost)
		to_chat(owner.mob, span_warning("You need [cost] triumphs to pick [trait.name]. You have [balance]."))
		return FALSE
	adjust_triumphs(owner, -cost, TRUE, "Triumph Shop: specific special [path_str]", FALSE, TRUE)
	owner.prefs.next_special_trait = trait_type
	owner.prefs.save_preferences()
	log_game("TRIUMPH SHOP: [owner.ckey] purchased specific special [path_str] ([trait?.name]) for [cost] triumphs.")
	to_chat(owner.mob, span_notice("Selected: <b>[trait?.name]</b>! Applies on your next spawn."))
	return TRUE

/datum/tgui_triumph_shop/proc/handle_clear_pending_special()
	if(!owner.prefs.next_special_trait)
		return FALSE
	owner.prefs.next_special_trait = null
	owner.prefs.save_preferences()
	to_chat(owner.mob, span_notice("Pending special trait cleared. No refund issued."))
	return TRUE
