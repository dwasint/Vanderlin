/datum/job/advclass/pilgrim/physicker
	title = "Physicker"
	tutorial = "Those who fail their studies, or are exiled from the towns they take \
				residence as feldshers in, often end up becoming wandering physickers. \
				Capable doctors nonetheless, they journey from place to place offering \
				their services."
	allowed_races = RACES_PLAYER_ALL
	outfit = /datum/outfit/pilgrim/physicker
	category_tags = list(CTAG_PILGRIM, CTAG_TOWNER)
	total_positions = 2
	apprentice_name = "Physicker Apprentice"
	cmode_music = 'sound/music/cmode/nobility/combat_physician.ogg'
	exp_types_granted = list(EXP_TYPE_MEDICAL)

	jobstats = list(
		STAT_INTELLIGENCE = -1,
		STAT_SPEED = 1
	)

	skills = list(
		/datum/attribute/skill/misc/reading = 3,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/misc/medicine = 3,
		/datum/attribute/skill/craft/alchemy = 1
	)

	traits = list(
		TRAIT_EMPATH,
		TRAIT_DEADNOSE
	)

/datum/outfit/pilgrim/physicker
	name = "Physicker (Pilgrim)"
	mask = /obj/item/clothing/face/phys
	head = /obj/item/clothing/head/roguehood/phys
	shoes = /obj/item/clothing/shoes/boots/leather
	shirt = /obj/item/clothing/shirt/undershirt/colored/black
	backl = /obj/item/storage/backpack/satchel/surgbag/shit
	pants = /obj/item/clothing/pants/tights/colored/random
	gloves = /obj/item/clothing/gloves/leather/phys
	armor = /obj/item/clothing/shirt/robe/phys
	neck = /obj/item/clothing/neck/phys
	belt = /obj/item/storage/belt/leather/rope
