/datum/job/advclass/mercenary/hollowdragoon
	title = "Hollow Dragoon"
	tutorial = "You rode out from Amber Hollow on your loyal steed, seeking coin from the wider reaches of Psydonia. \
	With armour salvaged from fallen knights and a spear in hand, you will fight for anyone, for a price."
	allowed_races = list(\
		SPEC_ID_HOLLOWKIN,\
		SPEC_ID_HARPY,\
	) // Technically should be humens too, but hollow's deserve something special too
	outfit = /datum/outfit/mercenary/dragoon
	category_tags = list(CTAG_MERCENARY)
	total_positions = 5
	cmode_music = 'sound/music/cmode/Combat_Dwarf.ogg'

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 2,
		STAT_SPEED = -1,
		STAT_INTELLIGENCE = -1
	)

	skills = list(
		/datum/attribute/skill/misc/riding = 4,
		/datum/attribute/skill/combat/polearms = 3,
		/datum/attribute/skill/labor/taming = 3,
		/datum/attribute/skill/combat/bows = 2,
		/datum/attribute/skill/combat/swords = 2,
		/datum/attribute/skill/combat/unarmed = 2,
		/datum/attribute/skill/craft/tanning = 2,
		/datum/attribute/skill/combat/wrestling = 2,
		/datum/attribute/skill/craft/crafting = 1,
		/datum/attribute/skill/misc/climbing = 1,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/misc/athletics = 3
	)

	traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_DEADNOSE
	)

/datum/job/advclass/mercenary/hollowdragoon/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.merctype = 9

	new /mob/living/simple_animal/hostile/retaliate/saiga/tame/saddled(get_turf(spawned))

/datum/outfit/mercenary/dragoon
	name = "Hollow Dragoon (Mercenary)"
	head = /obj/item/clothing/head/helmet/heavy/rust
	armor = /obj/item/clothing/armor/plate/rust
	neck = /obj/item/clothing/neck/gorget
	wrists = /obj/item/clothing/wrists/bracers/leather
	shirt = /obj/item/clothing/armor/gambeson/light
	gloves = /obj/item/clothing/gloves/plate/rust
	pants = /obj/item/clothing/pants/platelegs/rust
	shoes = /obj/item/clothing/shoes/boots/armor/light/rust
	belt = /obj/item/storage/belt/leather/mercenary
	beltr = /obj/item/flashlight/flare/torch/lantern
	beltl = /obj/item/weapon/sword
	backl = /obj/item/storage/backpack/satchel
	backr = /obj/item/weapon/polearm/spear
	scabbards = list(/obj/item/weapon/scabbard/sword)
	backpack_contents = list(
		/obj/item/storage/belt/pouch/coins/poor = 1,
		/obj/item/weapon/knife/dagger = 1
	)
