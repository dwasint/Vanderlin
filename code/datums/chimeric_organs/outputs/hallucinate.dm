/datum/chimeric_organs/output/hallucinate
	name = "hallucinating"
	desc = "Makes everyone around the user hallucinate temporarily."

	var/range = 5

/datum/chimeric_organs/output/hallucinate/set_values(node_purity, tier)
	. = ..()
	range *= (node_purity * 0.02) * (tier * 0.5)

/datum/chimeric_organs/output/hallucinate/trigger_effect(is_good, multiplier)
	. = ..()
	for(var/mob/living/carbon/listening_carbon in range(range * multiplier))
		handle_maniac_hallucinations(listening_carbon, 10)
