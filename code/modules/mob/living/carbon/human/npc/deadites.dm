/datum/outfit/vagrant/deadite/pre_equip(mob/living/carbon/human/H)
	. = ..()
	r_hand = null
	l_hand = null

/datum/outfit/hunter/deadite
	r_hand = null
	l_hand = null
	beltl = null
	backl = null
	backpack_contents = list(
		/obj/item/reagent_containers/powder/salt = 1,
		/obj/item/flint = 1,
		/obj/item/bait = 1,
	)
	neck = null

/mob/living/carbon/human/species/deadite
	ai_controller = /datum/ai_controller/human_deadite
	dodgetime = 30
	faction = list(FACTION_UNDEAD)
	var/static/list/possible_outfits = list(
		/datum/outfit/vagrant/deadite,
		/datum/outfit/prisoner,
		/datum/outfit/hunter/deadite,
	)

/mob/living/carbon/human/species/deadite/Initialize()
	race = pick(NPC_RACES_TYPES)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 0.1 SECONDS)

/mob/living/carbon/human/species/deadite/after_creation()
	. = ..()
	mind_initialize()
	zombie_check()

	if(length(possible_outfits))
		equipOutfit(pick(possible_outfits))
