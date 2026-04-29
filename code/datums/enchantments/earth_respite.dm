/datum/enchantment/pestra_gift
	enchantment_name = "Earth's Respite"
	examine_text = "The earth parts for this item."
	enchantment_color = "#4b2400"
	essence_recipe = list(
		/datum/thaumaturgical_essence/life = 10,
		/datum/thaumaturgical_essence/earth = 30
	)
	required_type = list(/obj/item/weapon/pick)

/datum/enchantment/pestra_gift/register_triggers(atom/item)
	. = ..()
	registered_signals += COMSIG_ITEM_DROPPED
	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	registered_signals += COMSIG_ITEM_PICKUP
	RegisterSignal(item, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	registered_signals += COMSIG_ITEM_NOW_ACTIVE
	RegisterSignal(item, COMSIG_ITEM_NOW_ACTIVE, PROC_REF(on_active))
	registered_signals += COMSIG_ITEM_NOLONGER_ACTIVE
	RegisterSignal(item, COMSIG_ITEM_NOLONGER_ACTIVE, PROC_REF(on_lose_active))

/datum/enchantment/pestra_gift/proc/on_equipped(obj/item/i, mob/living/user)
	if(i != user.get_active_held_item())
		return
	on_active(i, user)

/datum/enchantment/pestra_gift/proc/on_drop(obj/item/i, mob/living/user)
	on_lose_active(i, user)

/datum/enchantment/pestra_gift/proc/on_lose_active(obj/item/i, mob/living/user)
	user.attributes?.remove_attribute_modifier(/datum/attribute_modifier/earth_respite)

/datum/enchantment/pestra_gift/proc/on_active(obj/item/i, mob/living/user)
	user.attributes?.add_attribute_modifier(/datum/attribute_modifier/earth_respite)




