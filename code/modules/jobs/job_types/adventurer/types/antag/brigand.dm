/datum/job/advclass/bandit/brigand //Strength class, starts with axe or flails and medium armor training
	title = "Brigand"
	tutorial = "Cast from society, you use your powerful physical might and endurance to take from those who are weaker from you."
	outfit = /datum/outfit/bandit/brigand
	category_tags = list(CTAG_BANDIT)
	cmode_music = 'sound/music/cmode/antag/combat_bandit_brigand.ogg'

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 2,
		STAT_CONSTITUTION = 2,
		STAT_INTELLIGENCE = -1,
	)

	skills = list(
		/datum/attribute/skill/combat/polearms = 2,
		/datum/attribute/skill/combat/axesmaces = 3,
		/datum/attribute/skill/combat/shields = 3,
		/datum/attribute/skill/combat/wrestling = 3,
		/datum/attribute/skill/combat/unarmed = 3,
		/datum/attribute/skill/combat/swords = 2,
		/datum/attribute/skill/combat/whipsflails = 3,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/combat/bows = 2,
		/datum/attribute/skill/combat/crossbows = 2,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/craft/carpentry = 1,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/misc/climbing = 3,
		/datum/attribute/skill/misc/athletics = 3,
		/datum/attribute/skill/misc/sewing = 1,
		/datum/attribute/skill/misc/medicine = 1,
	)

	traits = list(
		TRAIT_MEDIUMARMOR,
	)

/datum/job/advclass/bandit/brigand/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/static/list/weapons = list(
		"Battleaxe & Cudgel" = list(/obj/item/weapon/axe/battle, /obj/item/weapon/mace/cudgel),
		"Flail & Shield" = list(/obj/item/weapon/shield/wood, /obj/item/weapon/flail),
	)

	spawned.select_equippable(player_client, weapons, message = "Choose your weapon.", title = "TAKE UP ARMS.")


/datum/outfit/bandit/brigand
	name = "Brigand (Bandit)"
	belt = /obj/item/storage/belt/leather
	pants = /obj/item/clothing/pants/trou/leather
	shirt = /obj/item/clothing/shirt/shortshirt/colored/random
	shoes = /obj/item/clothing/shoes/boots
	backr = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/needle/thorn = 1, /obj/item/natural/cloth = 1)
	mask = /obj/item/clothing/face/facemask/steel
	neck = /obj/item/clothing/neck/chaincoif/iron
	head = /obj/item/clothing/head/helmet/leather/volfhelm
	armor = /obj/item/clothing/armor/cuirass/iron
