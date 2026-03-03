/datum/outfit/overlord
	name = "Overlord"

/datum/outfit/overlord/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/helmet/skullcap/cult
	pants = /obj/item/clothing/pants/chainlegs
	shoes = /obj/item/clothing/shoes/shortboots
	neck = /obj/item/clothing/neck/chaincoif
	armor = /obj/item/clothing/shirt/robe/necromancer
	shirt = /obj/item/clothing/shirt/tunic/colored
	wrists = /obj/item/clothing/wrists/bracers
	gloves = /obj/item/clothing/gloves/chain
	belt = /obj/item/storage/belt/leather/black
	backl = /obj/item/storage/backpack/satchel
	beltr = /obj/item/reagent_containers/glass/bottle/manapot
	beltl = /obj/item/weapon/knife/dagger/steel
	r_hand = /obj/item/weapon/polearm/woodstaff

	H.set_skillrank(/datum/attribute/skill/misc/reading, 6, TRUE)
	H.set_skillrank(/datum/attribute/skill/craft/alchemy, 5, TRUE)
	H.set_skillrank(/datum/attribute/skill/magic/arcane, 5, TRUE)
	H.set_skillrank(/datum/attribute/skill/misc/riding, 4, TRUE)
	H.set_skillrank(/datum/attribute/skill/combat/polearms, 4, TRUE)
	H.set_skillrank(/datum/attribute/skill/combat/wrestling, 3, TRUE)
	H.set_skillrank(/datum/attribute/skill/combat/unarmed, 1, TRUE)
	H.set_skillrank(/datum/attribute/skill/misc/swimming, 1, TRUE)
	H.set_skillrank(/datum/attribute/skill/misc/climbing, 1, TRUE)
	H.set_skillrank(/datum/attribute/skill/misc/athletics, 1, TRUE)
	H.set_skillrank(/datum/attribute/skill/combat/swords, 2, TRUE)
	H.set_skillrank(/datum/attribute/skill/combat/knives, 2, TRUE)
	H.set_skillrank(/datum/attribute/skill/craft/crafting, 1, TRUE)
	H.adjust_skillrank(/datum/attribute/skill/labor/mathematics, 4, TRUE)

	H.change_stat(STAT_STRENGTH, -1)
	H.change_stat(STAT_INTELLIGENCE, 5)
	H.change_stat(STAT_CONSTITUTION, 5)
	H.change_stat(STAT_ENDURANCE, -1)
	H.change_stat(STAT_SPEED, -1)
	H.adjust_spell_points(17)
	H.grant_language(/datum/language/undead)
	if(H.dna?.species)
		H.dna.species.native_language = "Zizo Chant"
		H.dna.species.accent_language = H.dna.species.get_accent(H.dna.species.native_language)
	H.dna.species.soundpack_m = new /datum/voicepack/lich()
	H.ambushable = FALSE

	addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, choose_name_popup), "OVERLORD"), 5 SECONDS)
