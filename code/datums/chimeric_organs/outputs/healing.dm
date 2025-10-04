
/datum/chimeric_organs/output/healing
	name = "restoring"
	desc = "When activated heals the corresponding damage type"

	var/healing_type = BRUTE
	var/amount_healed = 5

/datum/chimeric_organs/output/healing/set_values(node_purity, tier)
	. = ..()
	healing_type = pick(BRUTE, OXY, TOX, BURN, CLONE)
	amount_healed *= (node_purity * 0.02) * (tier * 0.5)

/datum/chimeric_organs/output/healing/trigger_effect(multiplier)
	. = ..()
	if(istype(attached_input, /datum/chimeric_organs/input/damage))
		var/datum/chimeric_organs/input/damage/actual_type = attached_input
		if(actual_type.type == type)
			to_chat(hosted_carbon, span_warning("The feedback loop generated from your [attached_organ.name] is causing severe damage extraction is recommended!"))
			attached_organ.applyOrganDamage(30) // ouchies
			return

	hosted_carbon.apply_damage(-amount_healed * multiplier, healing_type, forced = TRUE)
