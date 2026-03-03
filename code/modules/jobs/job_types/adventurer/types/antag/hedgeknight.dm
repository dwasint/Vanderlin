/datum/job/advclass/bandit/hedgeknight //heavy knight class - just like black knight adventurer class. starts with heavy armor training and plate, but less weapon skills than brigand, sellsword and knave
	title = "Hedge Knight"
	tutorial = "A noble fallen from grace, your tarnished armor sits upon your shoulders as a heavy reminder of the life you've lost. Take back what is rightfully yours."
	outfit = /datum/outfit/bandit/hedgeknight
	category_tags = list(CTAG_BANDIT)
	cmode_music = 'sound/music/cmode/antag/CombatBandit1.ogg'

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 1,
		STAT_CONSTITUTION = 2,
		STAT_INTELLIGENCE = 1,
		STAT_SPEED = 1,
	)

	skills = list(
		/datum/attribute/skill/combat/polearms = 3,
		/datum/attribute/skill/combat/swords = 3,
		/datum/attribute/skill/combat/shields = 3,
		/datum/attribute/skill/combat/axesmaces = 3,
		/datum/attribute/skill/combat/wrestling = 3,
		/datum/attribute/skill/combat/unarmed = 3,
		/datum/attribute/skill/misc/athletics = 3,
		/datum/attribute/skill/misc/swimming = 1,
		/datum/attribute/skill/misc/climbing = 3,
		/datum/attribute/skill/misc/reading = 3,
		/datum/attribute/skill/misc/riding = 4,
		/datum/attribute/skill/craft/cooking = 1,
		/datum/attribute/skill/labor/butchering = 1,
		/datum/attribute/skill/labor/mathematics = 3,
	)

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
		TRAIT_NOBLE_BLOOD,
	)

/datum/outfit/bandit/hedgeknight
	name = "Hedge Knight (Bandit)"
	head = /obj/item/clothing/head/helmet/heavy/rust
	neck = /obj/item/clothing/neck/gorget
	armor = /obj/item/clothing/armor/plate/rust
	shirt = /obj/item/clothing/armor/gambeson/heavy/colored/dark
	wrists = /obj/item/clothing/wrists/bracers
	gloves = /obj/item/clothing/gloves/plate/rust
	pants = /obj/item/clothing/pants/platelegs/rust
	shoes = /obj/item/clothing/shoes/boots/armor/light/rust
	belt = /obj/item/storage/belt/leather
	beltr = /obj/item/weapon/sword/long
	backr = /obj/item/storage/backpack/satchel/black
	backl = /obj/item/weapon/shield/tower/metal
	backpack_contents = list(/obj/item/weapon/knife/dagger = 1)
