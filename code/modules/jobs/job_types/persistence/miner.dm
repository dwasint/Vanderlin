/datum/job/persistence/miner
	title = "Mineworker"
	tutorial = "You're a mineworker, ensure the settlement has stone and ores."
	department_flag = SERFS
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = FACTION_TOWN
	outfit = /datum/outfit/miner_p
	cmode_music = 'sound/music/cmode/towner/CombatTowner.ogg'

	jobstats = list(
		STAT_CONSTITUTION = 1,
		STAT_ENDURANCE = 1
	)

	skills = list(
		/datum/attribute/skill/combat/knives = 1,
		/datum/attribute/skill/combat/unarmed = 1,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/craft/crafting = 1,
		/datum/attribute/skill/misc/climbing = 1,
		/datum/attribute/skill/misc/swimming = 1,
		/datum/attribute/skill/misc/athletics = 1,
		/datum/attribute/skill/combat/axesmaces = 2,
		/datum/attribute/skill/labor/mining = 4,
		/datum/attribute/skill/craft/masonry = 2
	)

/datum/job/persistence/miner/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(prob(50))
		spawned.cmode_music = 'sound/music/cmode/towner/CombatTowner2.ogg'

	spawned.adjust_stat_modifier(STATMOD_JOB, list(
		STAT_STRENGTH = rand(0, 1),
		STAT_CONSTITUTION = rand(0, 1),
		STAT_ENDURANCE = rand(0, 1),
	))



/datum/outfit/miner_p
	name = "Mineworker"
	head = /obj/item/clothing/head/helmet/leather/minershelm
	shirt = /obj/item/clothing/shirt/undershirt/colored/random
	shoes = /obj/item/clothing/shoes/boots/leather

	beltl = /obj/item/weapon/pick
	backr = /obj/item/weapon/shovel
	backl = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/weapon/knife/villager = 1
	)


/datum/outfit/miner_p/pre_equip(mob/living/carbon/human/equipped_human)
	. = ..()
	pants = pick(/obj/item/clothing/pants/trou, /obj/item/clothing/pants/tights/colored/random)
	armor = pick(/obj/item/clothing/armor/leather/vest, /obj/item/clothing/armor/gambeson/light/striped)
	belt = pick(/obj/item/storage/belt/leather, /obj/item/storage/belt/leather/rope)
