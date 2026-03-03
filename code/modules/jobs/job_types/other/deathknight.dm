/datum/job/skeleton/knight
	title = "Death Knight"

	outfit = /datum/outfit/deathknight
	cmode_music = 'sound/music/cmode/combat_weird.ogg'
	antag_role = /datum/antagonist/skeleton/knight

	jobstats = list(
		STAT_STRENGTH = 3,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,
		STAT_INTELLIGENCE = 3,
		STAT_PERCEPTION = 2
	)

	skills = list(
		/datum/attribute/skill/combat/polearms = 3,
		/datum/attribute/skill/combat/axesmaces = 3,
		/datum/attribute/skill/combat/wrestling = 3,
		/datum/attribute/skill/combat/unarmed = 3,
		/datum/attribute/skill/combat/swords = 3,
		/datum/attribute/skill/combat/whipsflails = 3,
		/datum/attribute/skill/misc/riding = 3,
		/datum/attribute/skill/misc/athletics = 3,
	)

/datum/job/skeleton/knight/New()
	. = ..()
	traits += list(
		TRAIT_HEAVYARMOR,
		TRAIT_CRITICAL_WEAKNESS
	)

/datum/job/skeleton/knight/after_spawn(mob/living/carbon/spawned, client/player_client)
	SSmapping.retainer.death_knights |= spawned.mind
	. = ..()

	spawned.name = "Death Knight"
	spawned.real_name = "Death Knight"

	spawned.set_patron(/datum/patron/inhumen/zizo)

/datum/outfit/deathknight
	belt = /obj/item/storage/belt/leather
	pants = /obj/item/clothing/pants/platelegs/ancient
	shoes = /obj/item/clothing/shoes/boots/armor/ancient
	armor = /obj/item/clothing/armor/plate/ancient
	gloves = /obj/item/clothing/gloves/plate/ancient
	backl = /obj/item/weapon/polearm/halberd/bardiche/ancient
	backr = /obj/item/weapon/shield/tower/metal/ancient
	beltr = /obj/item/weapon/flail/sflail/ancient
	shirt = /obj/item/clothing/armor/chainmail/hauberk/ancient
	head = /obj/item/clothing/head/helmet/heavy/ancient
	wrists = /obj/item/clothing/wrists/bracers/ancient
	neck = /obj/item/clothing/neck/gorget/ancient

/obj/item/clothing/armor/plate/blkknight/death
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/shoes/boots/armor/blkknight/death
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/gloves/plate/blk/death
	color = CLOTHING_SOOT_BLACK

/obj/item/clothing/pants/platelegs/blk/death
	color = CLOTHING_SOOT_BLACK
