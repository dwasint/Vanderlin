GLOBAL_LIST_INIT(loadout_items, init_loadout_items())

/proc/init_loadout_items()
	. = list()
	for(var/datum/loadout_item/item as anything in subtypesof(/datum/loadout_item))
		if(IS_ABSTRACT(item))
			continue
		.[item] = new item()
	return .

/datum/loadout_item
	abstract_type = /datum/loadout_item
	/// Visible name for selection
	var/name = "Parent loadout datum"
	/// Visible description for item
	var/description
	/// Path to the item to spawn
	var/item_path
	/// Typepath of a /datum/award that must be unlocked to use this loadout item. Null = no requirement.
	var/required_award = null
	/// Triumphs spent per round to use this item once. Not saved.
	var/triumph_cost_single = 0
	/// Triumphs spent to permanently own this item. Saved to owned_loadout_items.
	var/triumph_cost_permanent = 0
	/// DMI file for the shop sprite, auto-derived from item_path in New()
	var/ui_icon = null
	/// Icon state within the DMI, auto-derived from item_path in New()
	var/ui_icon_state = null
	/// Category tab shown in the shop
	var/ui_category = "Miscellaneous"

/datum/loadout_item/New()
	. = ..()
	if(item_path && isnull(ui_icon))
		ui_icon = initial(item_path:icon)
		ui_icon_state = initial(item_path:icon_state)

/datum/loadout_item/proc/is_permanently_owned_by(client/C)
	return ("[type]" in C.prefs.owned_loadout_items)

/datum/loadout_item/proc/can_afford_single(client/C)
	if(!triumph_cost_single)
		return TRUE
	return get_triumph_amount(C.ckey) >= triumph_cost_single

/datum/loadout_item/proc/can_afford_permanent(client/C)
	if(!triumph_cost_permanent)
		return TRUE
	return get_triumph_amount(C.ckey) >= triumph_cost_permanent

/// Returns TRUE if the given client has satisfied this loadout item's award requirement.
/datum/loadout_item/proc/is_unlocked_for(client/C)
	if(!required_award)
		return TRUE
	if(!C?.player_details?.achievements)
		return FALSE
	var/datum/award/A = SSachievements.awards[required_award]
	if(!A)
		return FALSE
	if(istype(A, /datum/award/achievement/progress))
		var/datum/award/achievement/progress/PA = A
		return C.player_details.achievements.get_achievement_status(required_award) >= PA.required_progress
	if(istype(A, /datum/award/achievement))
		return C.player_details.achievements.get_achievement_status(required_award) == TRUE
	if(istype(A, /datum/award/score))
		return C.player_details.achievements.get_achievement_status(required_award) > 0
	return FALSE
