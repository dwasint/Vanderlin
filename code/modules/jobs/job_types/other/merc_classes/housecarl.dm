/datum/attribute_holder/sheet/job/housecarl
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,
		STAT_PERCEPTION = 1,
		STAT_INTELLIGENCE = -1,
		STAT_SPEED = -2,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/medicine = 20,
	)

/datum/job/advclass/mercenary/housecarl
	title = "Elvish Housecarl"
	tutorial = "Once a mighty guard for your clan leader now freelancer looking to put bread on the table, you have ventured to distance lands for work. Either it be guarding the gold horde of the merchant or the life of the king, you and others like you have been sought out by many to protect their lives and property."
	allowed_races = list(SPEC_ID_ELF, SPEC_ID_HALF_ELF)
	outfit = /datum/outfit/mercenary/housecarl
	category_tags = list(CTAG_MERCENARY)
	total_positions = 4
	cmode_music = 'sound/music/cmode/adventurer/CombatWarrior.ogg'

	attribute_sheet = /datum/attribute_holder/sheet/job/housecarl

	traits = list(
		TRAIT_MEDIUMARMOR,
	)

/datum/job/advclass/mercenary/housecarl/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.merctype = 9

/datum/outfit/mercenary/housecarl
	name = "Housecarl (Mercenary)"
	head = /obj/item/clothing/head/helmet/nasal
	shoes = /obj/item/clothing/shoes/boots
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/colored/brown
	gloves = /obj/item/clothing/gloves/leather/black
	backr = /obj/item/weapon/polearm/halberd/bardiche/woodcutter
	wrists = /obj/item/clothing/wrists/bracers/leather
	shirt = /obj/item/clothing/armor/gambeson
	neck = /obj/item/clothing/neck/highcollier/iron
	armor = /obj/item/clothing/armor/chainmail/hauberk/iron
	belt = /obj/item/storage/belt/leather/mercenary/black
	beltr = /obj/item/storage/belt/pouch/coins/poor
	beltl = /obj/item/weapon/sword/short/iron
	pants = /obj/item/clothing/pants/trou/leather
	backl = /obj/item/storage/backpack/satchel
