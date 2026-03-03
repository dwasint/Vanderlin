/datum/job/advclass/combat/amazon
	title = "Amazon"
	tutorial = "A savage and deft warrior-women, you hail from the mysterious isle of Issa. In your youth you learned to partake in the hunts amid the treetops and proved your worth through countless bouts."
	allowed_sexes = list(FEMALE)
	allowed_races = list(SPEC_ID_HUMEN, SPEC_ID_DROW, SPEC_ID_HALF_DROW, SPEC_ID_TRITON)
	outfit = /datum/outfit/adventurer/amazon
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	category_tags = list(CTAG_ADVENTURER)
	cmode_music = 'sound/music/cmode/adventurer/CombatOutlander.ogg'

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_INTELLIGENCE = -1,
		STAT_ENDURANCE = 2,
		STAT_CONSTITUTION = 1,
		STAT_SPEED = 1
	)

	skills = list(
		/datum/attribute/skill/combat/polearms = 3,
		/datum/attribute/skill/combat/bows = 3,
		/datum/attribute/skill/combat/wrestling = 2,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/misc/reading = 4,
		/datum/attribute/skill/combat/unarmed = 3,
		/datum/attribute/skill/craft/crafting = 1,
		/datum/attribute/skill/misc/swimming = 2,
		/datum/attribute/skill/misc/medicine = 3,
		/datum/attribute/skill/misc/climbing = 3,
		/datum/attribute/skill/misc/riding = 2,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/craft/cooking = 1,
		/datum/attribute/skill/craft/tanning = 1
	)

	traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_DEADNOSE,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN
	)

/datum/outfit/adventurer/amazon
	name = "Amazon (Adventurer)"
	neck = /obj/item/ammo_holder/dartpouch/poisondarts
	backl = /obj/item/weapon/polearm/spear
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/short
	belt = /obj/item/storage/belt/leather/rope
	beltl = /obj/item/gun/ballistic/revolver/grenadelauncher/blowgun
	beltr = /obj/item/ammo_holder/quiver/arrows
	shoes = /obj/item/clothing/shoes/gladiator
	wrists = /obj/item/clothing/wrists/bracers/leather
	armor = /obj/item/clothing/armor/amazon_chainkini
	shoes = /obj/item/clothing/shoes/boots
