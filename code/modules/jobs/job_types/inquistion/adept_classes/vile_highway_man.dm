// Vile Highwayman. Your run of the mill swordsman, albeit fancy, smarter than the other two so he has some non combat related skills.
/datum/job/advclass/adept/highwayman
	title = "Vile Renegade"
	tutorial = "You were a former outlaw who has been given a chance to redeem yourself by the Inquisitor. You serve him and Psydon with your survival skills."
	outfit = /datum/outfit/adept/highwayman
	category_tags = list(CTAG_ADEPT)
	cmode_music = 'sound/music/cmode/towner/CombatGaffer.ogg'

	skills = list(
		/datum/attribute/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/attribute/skill/combat/whipsflails = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/attribute/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/attribute/skill/misc/riding = SKILL_LEVEL_NOVICE,
		/datum/attribute/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/misc/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/labor/mathematics = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/attribute/skill/combat/firearms = SKILL_LEVEL_NOVICE
	)

	traits = list(
		TRAIT_FORAGER,
		TRAIT_STEELHEARTED,
		TRAIT_KNOWBANDITS,
		TRAIT_INQUISITION,
		TRAIT_BLACKBAGGER,
		TRAIT_PSYDONIAN_GRIT,
		TRAIT_PSYDONITE,
	)

	jobstats = list(
		STAT_PERCEPTION = 1,
		STAT_INTELLIGENCE = 2,
		STAT_SPEED = 1,
		STAT_CONSTITUTION = -1
	)

	voicepack_m = /datum/voicepack/male/knight

/datum/job/advclass/adept/highwayman/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	GLOB.inquisition.add_member_to_school(spawned, "Order of the Venatari", -10, "Renegade")

/datum/outfit/adept/highwayman
	name = "Vile Renegade (Adept)"
	belt = /obj/item/storage/belt/leather
	armor = /obj/item/clothing/armor/leather/jacket/leathercoat/renegade
	head = /obj/item/clothing/head/helmet/leather/tricorn
	neck = /obj/item/clothing/neck/gorget/explosive
	beltl = /obj/item/weapon/sword/short/iron
	l_hand = /obj/item/weapon/whip // Great length, they don't need to be next to a person to help in apprehending them.
	pants = /obj/item/clothing/pants/trou/leather
	backpack_contents = list(
		/obj/item/storage/keyring/adept = 1,
		/obj/item/weapon/knife/dagger/silver/psydon = 1,
		/obj/item/clothing/head/inqarticles/blackbag = 1,
		/obj/item/inqarticles/garrote = 1,
	)
