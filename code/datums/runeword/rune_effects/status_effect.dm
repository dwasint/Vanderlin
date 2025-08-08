/datum/rune_effect/status
	var/trigger_chance = 25
	var/status_key = STATUS_KEY_BLEED
	var/intensity = 1

/datum/rune_effect/status/apply_effects_from_list(list/effects)
	if(effects.len >= 1)
		trigger_chance = effects[1]
	if(effects.len >= 2)
		intensity = effects[2]

/datum/rune_effect/status/bleed
	name = "bleed chance"

/datum/rune_effect/status/bleed/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	var/status_mod = (target.get_status_mod(status_key) * 0.01)

	if(!prob(trigger_chance * status_mod))
		return
	target.simple_add_wound(/datum/wound/slash/small)

/datum/rune_effect/status/ignite
	name = "ignite chance"
	status_key = STATUS_KEY_IGNITE

/datum/rune_effect/status/bleed/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	var/status_mod = (target.get_status_mod(status_key) * 0.01)

	if(!prob(trigger_chance * status_mod))
		return
	target.adjust_fire_stacks(intensity)

/datum/rune_effect/status/chill
	name = "chill chance"
	status_key = STATUS_KEY_CHILL

/datum/rune_effect/status/bleed/apply_combat_effect(mob/living/target, mob/living/user, damage_dealt)
	var/status_mod = (target.get_status_mod(status_key) * 0.01)

	if(!prob(trigger_chance * status_mod))
		return
	target.apply_status_effect(/datum/status_effect/debuff/chilled, 5 SECONDS * intensity)
