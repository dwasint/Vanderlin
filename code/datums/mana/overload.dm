/atom/movable/proc/process_mana_overload(effect_mult, seconds_per_tick)
	mana_overloaded = TRUE

/mob/process_mana_overload(effect_mult, seconds_per_tick)
	if (!mana_overloaded)
		to_chat(src, span_warning("You start feeling fuzzy and tingly all around..."))

	return ..()

/mob/living/carbon/process_mana_overload(effect_mult, seconds_per_tick = 1)
	. = ..()

	var/adjusted_mult = effect_mult * seconds_per_tick

	adjust_disgust(adjusted_mult)

	if (effect_mult > MANA_OVERLOAD_DAMAGE_THRESHOLD)
		apply_damage(MANA_OVERLOAD_BASE_DAMAGE * adjusted_mult, damagetype = BRUTE, forced = TRUE, spread_damage = TRUE)

/atom/movable/proc/stop_mana_overload()
	mana_overloaded = FALSE

/mob/stop_mana_overload()
	to_chat(src, span_notice("You feel your body returning to normal."))

	return ..()
