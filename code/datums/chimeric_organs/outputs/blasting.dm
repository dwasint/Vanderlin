
/datum/chimeric_organs/output/blasting
	name = "blasting"
	desc = "When activated you explode"

/datum/chimeric_organs/output/blasting/trigger_effect(multiplier)
	. = ..()
	cell_explosion(get_turf(hosted_carbon), (20 + (node_purity * 0.1)), 0.01)
