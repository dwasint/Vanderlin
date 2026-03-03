/datum/job/cook
	title = "Cook"
	tutorial = "Slice, chop, and into the pot... \
	you work closely with the innkeep to prepare meals for all the hungry mouths of Vanderlin. \
	You've spent more nites than you can count cutting meat and vegetables until your fingers are bloody and raw, but it's honest work."
	department_flag = PEASANTS
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = FACTION_TOWN
	total_positions = 3
	spawn_positions = 3
	bypass_lastclass = TRUE

	allowed_races = RACES_PLAYER_ALL

	outfit = /datum/outfit/cook
	display_order = JDO_COOK
	give_bank_account = 8
	cmode_music = 'sound/music/cmode/towner/CombatInn.ogg'

	job_bitflag = BITFLAG_CONSTRUCTOR

	jobstats = list(
		STAT_ENDURANCE = 1,
		STAT_INTELLIGENCE = 1,
		STAT_CONSTITUTION = 1,
	)

	skills = list(
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/craft/cooking = 4,
		/datum/attribute/skill/craft/crafting = 1,
		/datum/attribute/skill/misc/sewing = 1,
		/datum/attribute/skill/labor/butchering = 3,
		/datum/attribute/skill/labor/taming = 1,
		/datum/attribute/skill/labor/farming = 1
	)

/datum/job/cook/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.age == AGE_OLD)
		spawned.adjust_skillrank(/datum/attribute/skill/craft/cooking, 1, TRUE)

/datum/outfit/cook
	name = "Cook"
	belt = /obj/item/storage/belt/leather/rope
	beltl = /obj/item/key/tavern
	beltr = /obj/item/weapon/knife/villager
	head = /obj/item/clothing/head/cookhat
	neck = /obj/item/storage/belt/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/simpleshoes
	cloak = /obj/item/clothing/cloak/apron/cook

	backpack_contents = list(
		/obj/item/recipe_book/cooking = 1
	)

/datum/outfit/cook/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == MALE)
		pants = /obj/item/clothing/pants/tights/colored/random
		shirt = /obj/item/clothing/shirt/shortshirt/colored/random
	else
		shirt = /obj/item/clothing/shirt/undershirt/lowcut
		armor = /obj/item/clothing/armor/corset
		pants = /obj/item/clothing/pants/skirt/colored/red



