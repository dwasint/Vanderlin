/datum/chimeric_organs/output/vomit
	name = "nauseous"
	desc = "When activated causes you to vomit"

/datum/chimeric_organs/output/vomit/trigger_effect(multiplier)
	. = ..()
	hosted_carbon.vomit()
