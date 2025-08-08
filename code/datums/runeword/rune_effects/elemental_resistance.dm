/datum/rune_effect/resistance
	var/resistance_type = FIRE_DAMAGE
	var/resistance_value = 0
	var/max_resistance_bonus = 0

/datum/rune_effect/resistance/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		resistance_value = effects[1]
	if(effects.len >= 2)
		max_resistance_bonus = effects[2]

/datum/rune_effect/resistance/proc/apply_to_item(obj/item/item)
	switch(resistance_type)
		if(FIRE_DAMAGE)
			item.fire_res += resistance_value
			item.max_fire_res += max_resistance_bonus
		if(COLD_DAMAGE)
			item.cold_res += resistance_value
			item.max_cold_res += max_resistance_bonus
		if(LIGHTNING_DAMAGE)
			item.lightning_res += resistance_value
			item.max_lightning_res += max_resistance_bonus

/datum/rune_effect/resistance/fire
	name = "fire resistance"
	resistance_type = FIRE_DAMAGE

/datum/rune_effect/resistance/cold
	name = "cold resistance"
	resistance_type = COLD_DAMAGE

/datum/rune_effect/resistance/lightning
	name = "lightning resistance"
	resistance_type = LIGHTNING_DAMAGE
