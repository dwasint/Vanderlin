/datum/job/advclass/pilgrim/hunter
	title = "Hunter"
	f_title = "Huntress"
	tutorial = "Peasants that thrive on the woods, hunting creechers for pelt and hide, \
				or the boons of Dendor for their meat to sell, or consume."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/pilgrim/hunter
	category_tags = list(CTAG_PILGRIM)
	apprentice_name = "Hunter Apprentice"
	cmode_music = 'sound/music/cmode/towner/CombatBeggar.ogg'

	jobstats = list(
		STAT_INTELLIGENCE = 1,
		STAT_PERCEPTION = 3
	)

	skills = list(
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/craft/tanning = 3,
		/datum/attribute/skill/combat/bows = 3,
		/datum/attribute/skill/combat/crossbows = 2,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/craft/cooking = 1,
		/datum/attribute/skill/labor/butchering = 2,
		/datum/attribute/skill/labor/taming = 3,
		/datum/attribute/skill/misc/medicine = 1,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/misc/sneaking = 2,
		/datum/attribute/skill/craft/traps = 3,
		/datum/attribute/skill/misc/athletics = 3,
		/datum/attribute/skill/misc/climbing = 2,
		/datum/attribute/skill/misc/swimming = 1,
		/datum/attribute/skill/misc/reading = 1
	)

/datum/job/advclass/pilgrim/hunter/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.age == AGE_OLD)
		spawned.adjust_skillrank(/datum/attribute/skill/combat/bows, 1, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/craft/traps, 1, TRUE)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_PERCEPTION, -2)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_INTELLIGENCE, -1)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_ENDURANCE, -1)

/datum/outfit/pilgrim/hunter
	name = "Hunter (Pilgrim)"
	pants = /obj/item/clothing/pants/tights/colored/random
	neck = /obj/item/storage/belt/pouch/coins/poor
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/colored/brown
	backr = /obj/item/storage/backpack/satchel
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
	belt = /obj/item/storage/belt/leather
	beltr = /obj/item/ammo_holder/quiver/arrows
	beltl = /obj/item/storage/meatbag
	gloves = /obj/item/clothing/gloves/leather
	backpack_contents = list(
		/obj/item/reagent_containers/powder/salt = 1,
		/obj/item/flint = 1,
		/obj/item/bait = 1,
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/flashlight/flare/torch/lantern = 1
	)

/datum/outfit/pilgrim/hunter/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	shirt = pick(/obj/item/clothing/shirt/undershirt/colored/random, /obj/item/clothing/shirt/shortshirt/colored/random)
	shoes = pick(/obj/item/clothing/shoes/simpleshoes, /obj/item/clothing/shoes/boots/leather)
	head = pick(/obj/item/clothing/head/brimmed, /obj/item/clothing/head/papakha, /obj/item/clothing/head/hatfur, /obj/item/clothing/head/headband/colored/red)
