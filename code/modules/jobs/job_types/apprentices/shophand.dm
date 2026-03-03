/datum/job/shophand
	title = "Shophand"
	tutorial = "You work under the greedy eyes of the Merchant who has shackled you to the drudgery of employment. \
	Tasked with handling customers, organizing shelves, and taking inventory, your work is mind-numbing and repetitive. \
	Despite its mundanity however, it keeps a roof over your head and teaches you the art of mercantilism. \
	With enough time, you will become more than a glorified clerk and open a business that rivals all others."
	department_flag = COMPANY
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	display_order = JDO_SHOPHAND
	is_quest_giver = TRUE
	give_bank_account = 10
	bypass_lastclass = TRUE
	can_have_apprentices = FALSE

	allowed_races = RACES_PLAYER_ALL
	allowed_ages = list(AGE_CHILD, AGE_ADULT)

	outfit = /datum/outfit/shophand
	display_order = JDO_SHOPHAND
	give_bank_account = 10
	bypass_lastclass = TRUE
	can_have_apprentices = FALSE
	cmode_music = 'sound/music/cmode/towner/CombatTowner2.ogg'
	exp_types_granted = list(EXP_TYPE_MERCHANT_COMPANY)

	exp_types_granted = list(EXP_TYPE_MERCHANT_COMPANY)

	jobstats = list(
		STAT_SPEED = 1,
		STAT_INTELLIGENCE = 1,
		STAT_FORTUNE = 1
	)

	skills = list(
		/datum/attribute/skill/misc/stealing = 4,
		/datum/attribute/skill/misc/sneaking = 2,
		/datum/attribute/skill/misc/reading = 3,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/misc/athletics = 1,
		/datum/attribute/skill/misc/lockpicking = 2,
		/datum/attribute/skill/labor/mathematics = 3
	)

	traits = list(
		TRAIT_SEEPRICES
	)

/datum/job/shophand/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/random_roll = rand(1, 3)
	switch(random_roll)
		if(1)
			spawned.adjust_skillrank(/datum/attribute/skill/combat/crossbows, 1, TRUE)
		if(2)
			spawned.adjust_skillrank(/datum/attribute/skill/combat/bows, 1, TRUE)
		if(3)
			spawned.adjust_skillrank(/datum/attribute/skill/combat/swords, 1, TRUE)
			spawned.adjust_skillrank(/datum/attribute/skill/combat/axesmaces, 1, TRUE)
			spawned.adjust_stat_modifier(STATMOD_JOB, STAT_STRENGTH, 1)

/datum/outfit/shophand
	name = "Shophand Base"
	head = /obj/item/clothing/head/chaperon
	pants = /obj/item/clothing/pants/tights
	shoes = /obj/item/clothing/shoes/simpleshoes
	belt = /obj/item/storage/belt/leather
	beltr = /obj/item/storage/belt/pouch/coins/poor
	beltl = /obj/item/storage/keyring/stevedore
	backr = /obj/item/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/fingerless

/datum/outfit/shophand/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == FEMALE)
		shirt = /obj/item/clothing/shirt/dress/gen/colored/blue
	else
		shirt = /obj/item/clothing/shirt/undershirt/colored/blue
