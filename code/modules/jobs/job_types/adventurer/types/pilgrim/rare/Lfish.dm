/datum/job/advclass/pilgrim/rare/fishermaster
	title = "Master Fisher"
	tutorial = "Seafarers who have mastered the tides, and are able to catch any fish with ease \
	no matter the body of water. They have learned to thrive off the gifts of Abyssor, not simply survive."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/pilgrim/fishermaster
	total_positions = 1
	roll_chance = 0
	category_tags = list(CTAG_PILGRIM, CTAG_TOWNER)
	apprentice_name = "Fisher Apprentice"
	cmode_music = 'sound/music/cmode/towner/CombatTowner.ogg'
	is_recognized = TRUE

	jobstats = list(
		STAT_CONSTITUTION = 2,
		STAT_PERCEPTION = 2
	)

	skills = list(
		/datum/attribute/skill/combat/wrestling = 1,
		/datum/attribute/skill/combat/unarmed = 1,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/misc/swimming = 5,
		/datum/attribute/skill/craft/cooking = 3,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/labor/fishing = 5,
		/datum/attribute/skill/misc/medicine = 1,
		/datum/attribute/skill/misc/athletics = 3,
		/datum/attribute/skill/misc/reading = 1
	)

/datum/job/advclass/pilgrim/rare/fishermaster/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.age == AGE_OLD)
		spawned.adjust_skillrank(/datum/attribute/skill/labor/fishing, 1, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/combat/polearms, 1, TRUE)

/datum/outfit/pilgrim/fishermaster
	name = "Master Fisher (Pilgrim)"
	neck = /obj/item/storage/belt/pouch/coins/mid
	head = /obj/item/clothing/head/fisherhat
	backr = /obj/item/storage/backpack/satchel
	armor = /obj/item/clothing/armor/leather/jacket/sea
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/weapon/knife/hunting
	backpack_contents = list(
		/obj/item/natural/worms = 2,
		/obj/item/weapon/shovel/small = 1
	)

/datum/outfit/pilgrim/fishermaster/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == MALE)
		pants = /obj/item/clothing/pants/trou
		shirt = /obj/item/clothing/shirt/shortshirt/colored/random
		shoes = /obj/item/clothing/shoes/boots/leather
		backl = /obj/item/fishingrod/fisher
		beltr = /obj/item/cooking/pan
	else
		pants = /obj/item/clothing/pants/trou
		shoes = /obj/item/clothing/shoes/boots/leather
		shirt = /obj/item/clothing/shirt/shortshirt/colored/random
		beltr = /obj/item/fishingrod/fisher
