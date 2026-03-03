/datum/job/advclass/combat/bladesinger
	title = "Bladesinger"
	tutorial = "Your vigil over the elven cities has long since ended. Though dutiful, the inevitable happened and now you hope these lands have use for your talents."
	allowed_races = list(SPEC_ID_ELF)
	total_positions = 1
	outfit = /datum/outfit/folkhero/bladesinger
	category_tags = list(CTAG_FOLKHEROES)
	cmode_music = 'sound/music/cmode/adventurer/CombatWarrior.ogg'

	skills = list(
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/combat/swords = 4,
		/datum/attribute/skill/combat/bows = 2,
		/datum/attribute/skill/combat/wrestling = 2,
		/datum/attribute/skill/combat/unarmed = 2,
		/datum/attribute/skill/misc/swimming = 2,
		/datum/attribute/skill/misc/climbing = 2,
		/datum/attribute/skill/misc/athletics = 3,
		/datum/attribute/skill/misc/reading = 2,
	)

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_CONSTITUTION = 1,
		STAT_ENDURANCE = 1,
		STAT_SPEED = 1,
	)

	traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_DUALWIELDER,
	)

/datum/job/advclass/combat/bladesinger/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.gender == FEMALE)
		spawned.underwear = "Femleotard"
		spawned.underwear_color = CLOTHING_SOOT_BLACK
		spawned.update_body()

/datum/outfit/folkhero/bladesinger
	name = "Bladesinger (Folkhero)"
	pants = /obj/item/clothing/pants/tights/colored/black
	backr = /obj/item/weapon/sword/long/greatsword/elfgsword
	beltl = /obj/item/storage/belt/pouch/coins/mid
	shoes = /obj/item/clothing/shoes/boots/rare/elfplate/welfplate
	gloves = /obj/item/clothing/gloves/rare/elfplate/welfplate
	belt = /obj/item/storage/belt/leather
	shirt = /obj/item/clothing/shirt/undershirt/colored/black
	armor = /obj/item/clothing/armor/rare/elfplate/welfplate
	backl = /obj/item/storage/backpack/satchel
	head = /obj/item/clothing/head/rare/elfplate/welfplate
	neck = /obj/item/clothing/neck/chaincoif
