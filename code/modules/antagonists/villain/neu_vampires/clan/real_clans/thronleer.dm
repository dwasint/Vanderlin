
/datum/clan_leader/thronleer
	lord_spells = list(
		/obj/effect/proc_holder/spell/targeted/mansion_portal,
		/obj/effect/proc_holder/spell/targeted/shapeshift/gaseousform
	)
	lord_verbs = list(
		/mob/living/carbon/human/proc/demand_submission,
		/mob/living/carbon/human/proc/punish_spawn
	)
	lord_traits = list(TRAIT_HEAVYARMOR)
	lord_title = "Elder"

/datum/clan/thronleer
	name = "House Thronleer"
	desc = "TBA"
	curse = "Weakness of the soul."
	clane_covens = list(
		/datum/coven/obfuscate,
		/datum/coven/presence,
	)
	leader = /datum/clan_leader/thronleer
