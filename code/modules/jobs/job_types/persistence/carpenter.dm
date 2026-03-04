/datum/job/persistence/carpenter
	title = "Woodworker"
	tutorial = "You're a woodworker, ensure the settlement isn't a bunch of tents."
	department_flag = PEASANTS
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = FACTION_TOWN
	outfit = /datum/outfit/carpenter_p
	cmode_music = 'sound/music/cmode/towner/CombatTowner.ogg'

	skills = list(
		/datum/attribute/skill/combat/knives = 1,
		/datum/attribute/skill/combat/unarmed = 1,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/craft/crafting = 1,
		/datum/attribute/skill/misc/climbing = 2,
		/datum/attribute/skill/misc/swimming = 1,
		/datum/attribute/skill/misc/athletics = 1,
		/datum/attribute/skill/combat/axesmaces = 2,
		/datum/attribute/skill/craft/carpentry = 4,
		/datum/attribute/skill/labor/lumberjacking = 2
	)

	traits = list()

/datum/job/persistence/carpenter/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(prob(50))
		spawned.cmode_music = 'sound/music/cmode/towner/CombatTowner2.ogg'

	spawned.adjust_stat_modifier(STATMOD_JOB, list(
		STAT_STRENGTH = rand(0, 1),
		STAT_CONSTITUTION = rand(0, 1),
		STAT_ENDURANCE = rand(0, 1),
	))


/datum/outfit/carpenter_p
	name = "Woodworker"
	shirt = /obj/item/clothing/shirt/undershirt/colored/random
	shoes = /obj/item/clothing/shoes/boots/leather

	beltl = /obj/item/weapon/hammer/iron
	beltr = /obj/item/weapon/axe/iron
	backl = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/recipe_book/carpentry = 1,
		/obj/item/weapon/knife/villager = 1
	)

/datum/outfit/carpenter_p/pre_equip(mob/living/carbon/human/equipped_human)
	. = ..()
	head = pick(/obj/item/clothing/head/hatfur, /obj/item/clothing/head/hatblu, /obj/item/clothing/head/brimmed)
	armor = pick(/obj/item/clothing/armor/leather/vest, /obj/item/clothing/armor/gambeson/light/striped)
	pants = pick(/obj/item/clothing/pants/trou, /obj/item/clothing/pants/tights/colored/random)
	belt = pick(/obj/item/storage/belt/leather, /obj/item/storage/belt/leather/rope)
