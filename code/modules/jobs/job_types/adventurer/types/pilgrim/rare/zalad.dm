/datum/job/advclass/pilgrim/rare/zaladin
	title = "Zaladin Emir"
	tutorial = "An Emir hailing from Deshret, here on business for the Mercator's Guild."
	allowed_races = RACES_PLAYER_ZALADIN
	outfit = /datum/outfit/pilgrim/zalad
	category_tags = list(CTAG_PILGRIM)
	total_positions = 1
	cmode_music = 'sound/music/cmode/adventurer/CombatOutlander.ogg'
	is_recognized = TRUE
	honorary = "Emir"
	honorary_f = "Amirah"

	jobstats = list(
		STAT_INTELLIGENCE = 1,
		STAT_ENDURANCE = 2
	)

	skills = list(
		/datum/attribute/skill/misc/swimming = 2,
		/datum/attribute/skill/misc/climbing = 3,
		/datum/attribute/skill/misc/riding = 4,
		/datum/attribute/skill/misc/reading = 4,
		/datum/attribute/skill/misc/music = 1,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/craft/cooking = 2,
		/datum/attribute/skill/combat/crossbows = 2,
		/datum/attribute/skill/combat/wrestling = 2,
		/datum/attribute/skill/combat/unarmed = 2,
		/datum/attribute/skill/combat/swords = 3,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/labor/mathematics = 3
	)

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_NOBLE_BLOOD,
		TRAIT_NOBLE_POWER,
		TRAIT_FOREIGNER
	)

	languages = list(/datum/language/zalad)

/datum/job/advclass/pilgrim/rare/zaladin/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(spawned.dna?.species)
		if(spawned.dna.species.id == SPEC_ID_HUMEN)
			spawned.dna.species.native_language = "Zalad"
			spawned.dna.species.accent_language = spawned.dna.species.get_accent(spawned.dna.species.native_language)
		if(spawned.dna.species.id == SPEC_ID_HALF_ELF)
			if(spawned.dna.species.native_language == "Imperial")
				spawned.dna.species.native_language = "Zalad"
				spawned.dna.species.accent_language = spawned.dna.species.get_accent(spawned.dna.species.native_language)

/datum/outfit/pilgrim/zalad
	name = "Zaladin Emir (Pilgrim)"
	shoes = /obj/item/clothing/shoes/shalal
	gloves = /obj/item/clothing/gloves/leather
	head = /obj/item/clothing/head/crown/circlet
	cloak = /obj/item/clothing/cloak/raincloak/colored/purple
	armor = /obj/item/clothing/armor/gambeson/arming
	belt = /obj/item/storage/belt/leather/shalal
	beltl = /obj/item/weapon/sword/sabre/shalal
	beltr = /obj/item/flashlight/flare/torch/lantern
	backr = /obj/item/storage/backpack/satchel
	ring = /obj/item/clothing/ring/gold/guild_mercator
	shirt = /obj/item/clothing/shirt/tunic/colored/purple
	pants = /obj/item/clothing/pants/trou/leather
	neck = /obj/item/clothing/neck/shalal/emir
	backpack_contents = list(/obj/item/storage/belt/pouch/coins/veryrich = 1)

/datum/outfit/pilgrim/zalad/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == FEMALE)
		shirt = /obj/item/clothing/shirt/dress/silkdress/colored/black
