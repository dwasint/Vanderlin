/datum/job/forestguard
	title = "Forest Guard"
	tutorial = "You've been keeping the streets clean of neer-do-wells and taffers for most of your time in the garrison.\
	You've been through the wringer - alongside soldiers in the short-lived Goblin Wars. \
	The Wars were rough, the few who survived came back changed. Perhaps you'd agree. \
	\
	\n\n\
	A fellow soldier had been given the title of Forest Warden for their valorant efforts \
	and they've plucked you from one dangerous position into another. \
	At least with your battle-family by your side, you will never die alone."
	department_flag = GARRISON
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_FORGUARD
	faction = FACTION_TOWN
	total_positions = 4
	spawn_positions = 4
	bypass_lastclass = TRUE
	selection_color = "#0d6929"

	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL, AGE_CHILD)
	allowed_races = RACES_PLAYER_ALL
	blacklisted_species = list(SPEC_ID_HALFLING)
	give_bank_account = 30
	can_have_apprentices = FALSE
	cmode_music = 'sound/music/cmode/garrison/CombatForestGarrison2.ogg'

	outfit = /datum/outfit/forestguard
	advclass_cat_rolls = list(CTAG_FORGARRISON = 20)

	job_bitflag = BITFLAG_GARRISON

	exp_type = list(EXP_TYPE_GARRISON)
	exp_types_granted = list(EXP_TYPE_GARRISON, EXP_TYPE_COMBAT)
	exp_requirements = list(
		EXP_TYPE_GARRISON = 600
	)

/datum/job/forestguard/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	add_verb(spawned, /mob/proc/haltyell)

/datum/outfit/forestguard
	name = "Forest Guard Base"
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/leather
	belt = /obj/item/storage/belt/leather/fgarrison
	backl = /obj/item/storage/backpack/satchel

/datum/outfit/forestguard/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(SSmapping.config.map_name == "Rosewood")
		cloak = /obj/item/clothing/cloak/forrestercloak/snow
	else
		cloak = /obj/item/clothing/cloak/forrestercloak

/datum/job/advclass/forestguard
	exp_types_granted = list(EXP_TYPE_GARRISON, EXP_TYPE_COMBAT)

/datum/job/advclass/forestguard/infantry
	title = "Forest Ravager"
	tutorial = "In the goblin wars- you alone were deployed to the front lines, caving skulls and chopping legs - saving your family-at-arms through your reckless diversions. With your bloodied axe and flail, every swing and crack was another hatch on your tally. Now that the War's over, even with your indomitable spirit and tireless zeal - let's see if that still rings true."
	outfit = /datum/outfit/forestguard/infantry
	category_tags = list(CTAG_FORGARRISON)
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	blacklisted_species = list(SPEC_ID_HALFLING, SPEC_ID_KOBOLD, SPEC_ID_KOBOLD_FORMIKRAG)

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 3,
		STAT_CONSTITUTION = 3,
		STAT_SPEED = -1
	)

	skills = list(
		/datum/attribute/skill/misc/swimming = 3,
		/datum/attribute/skill/misc/climbing = 4,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/misc/riding = 2,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/labor/lumberjacking = 1,
		/datum/attribute/skill/craft/carpentry = 1,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/craft/tanning = 1,
		/datum/attribute/skill/combat/axesmaces = 3,
		/datum/attribute/skill/combat/whipsflails = 3,
		/datum/attribute/skill/combat/swords = 3,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/combat/shields = 3,
		/datum/attribute/skill/combat/bows = 1,
		/datum/attribute/skill/combat/wrestling = 3,
		/datum/attribute/skill/combat/unarmed = 3
	)

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_FORAGER,
		TRAIT_KNOWBANDITS
	)

/datum/outfit/forestguard/infantry
	name = "Forest Ravager"
	head = /obj/item/clothing/head/helmet/medium/decorated/skullmet
	neck = /obj/item/clothing/neck/gorget
	shirt = /obj/item/clothing/armor/chainmail/hauberk/iron
	beltl = /obj/item/weapon/flail/militia
	beltr = /obj/item/weapon/axe/iron
	armor = /obj/item/clothing/armor/leather/advanced/forrester
	backr = /obj/item/weapon/shield/heater
	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/belt/pouch/coins/poor = 1
	)

/datum/job/advclass/forestguard/ranger
	title = "Forest Ranger"
	tutorial = "In the Wars you were always one of the fastest, as well as one of the frailest in the platoon. Your trusty bow has served you well- of course, none you've set your sights on have found the tongue to disagree."
	outfit = /datum/outfit/forestguard/ranger
	category_tags = list(CTAG_FORGARRISON)
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	blacklisted_species = list(SPEC_ID_HALFLING, SPEC_ID_KOBOLD, SPEC_ID_KOBOLD_FORMIKRAG)

	jobstats = list(
		STAT_STRENGTH = -3,
		STAT_ENDURANCE = 1,
		STAT_PERCEPTION = 3,
		STAT_SPEED = 3
	)

	skills = list(
		/datum/attribute/skill/misc/swimming = 3,
		/datum/attribute/skill/misc/climbing = 4,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/misc/riding = 2,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/labor/lumberjacking = 1,
		/datum/attribute/skill/craft/carpentry = 1,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/craft/tanning = 1,
		/datum/attribute/skill/combat/bows = 3,
		/datum/attribute/skill/combat/crossbows = 3,
		/datum/attribute/skill/combat/knives = 3,
		/datum/attribute/skill/combat/axesmaces = 1,
		/datum/attribute/skill/combat/wrestling = 1
	)

	traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_FORAGER,
		TRAIT_KNOWBANDITS
	)

/datum/outfit/forestguard/ranger
	name = "Forest Ranger"
	head = /obj/item/clothing/head/helmet/medium/decorated/skullmet
	neck = /obj/item/clothing/neck/highcollier
	shirt = /obj/item/clothing/armor/gambeson
	beltl = /obj/item/weapon/knife/cleaver/combat
	beltr = /obj/item/ammo_holder/quiver/arrows
	armor = /obj/item/clothing/armor/leather/advanced/forrester
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/long
	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/belt/pouch/coins/poor = 1
	)

/datum/job/advclass/forestguard/reaver
	title = "Forest Reaver"
	tutorial = "In the Wars you took an oath to never shy from a hit. Axe in hand, thirsting for blood, you simply enjoy the <i>chaos of battle...</i>"
	outfit = /datum/outfit/forestguard/reaver
	category_tags = list(CTAG_FORGARRISON)
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	blacklisted_species = list(SPEC_ID_HALFLING, SPEC_ID_KOBOLD, SPEC_ID_KOBOLD_FORMIKRAG)

	jobstats = list(
		STAT_STRENGTH = 2,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,
		STAT_SPEED = 1
	)

	skills = list(
		/datum/attribute/skill/misc/swimming = 3,
		/datum/attribute/skill/misc/climbing = 4,
		/datum/attribute/skill/misc/athletics = 3,
		/datum/attribute/skill/misc/reading = 1,
		/datum/attribute/skill/misc/riding = 2,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/labor/lumberjacking = 1,
		/datum/attribute/skill/craft/carpentry = 1,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/craft/tanning = 1,
		/datum/attribute/skill/combat/wrestling = 3,
		/datum/attribute/skill/combat/unarmed = 3,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/combat/axesmaces = 3
	)

	traits = list(
		TRAIT_DUALWIELDER,
		TRAIT_MEDIUMARMOR,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_FORAGER,
		TRAIT_KNOWBANDITS
	)

/datum/outfit/forestguard/reaver
	name = "Forest Reaver"
	head = /obj/item/clothing/head/helmet/medium/decorated/skullmet
	neck = /obj/item/clothing/neck/gorget
	shirt = /obj/item/clothing/armor/chainmail/hauberk/iron
	beltl = /obj/item/weapon/mace/steel/morningstar
	armor = /obj/item/clothing/armor/leather/advanced/forrester
	backr = /obj/item/weapon/polearm/halberd/bardiche/woodcutter
	beltr = /obj/item/weapon/axe/iron
	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/belt/pouch/coins/poor = 1
	)

/datum/job/advclass/forestguard/ruffian
	title = "Forest Ruffian"
	tutorial = "For your terrible orphan pranks and antics in the city, you were rounded up by the city's Watch and put to work in the infamous forest garrison. \n\n A ruffian by circumstance, a proven listener of war stories - you might just become more than a troublemaker."
	outfit = /datum/outfit/forestguard/ruffian
	category_tags = list(CTAG_FORGARRISON)
	allowed_ages = list(AGE_CHILD)
	blacklisted_species = list(SPEC_ID_HALFLING, SPEC_ID_KOBOLD, SPEC_ID_KOBOLD_FORMIKRAG)

	jobstats = list(
		STAT_PERCEPTION = 1
	)

	skills = list(
		/datum/attribute/skill/misc/swimming = 3,
		/datum/attribute/skill/misc/climbing = 4,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/craft/carpentry = 1,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/labor/butchering = 2,
		/datum/attribute/skill/combat/bows = 1,
		/datum/attribute/skill/combat/crossbows = 1,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/combat/axesmaces = 1,
		/datum/attribute/skill/combat/wrestling = 1,
		/datum/attribute/skill/craft/cooking = 2,
		/datum/attribute/skill/misc/sneaking = 2,
		/datum/attribute/skill/misc/stealing = 3,
		/datum/attribute/skill/craft/tanning = 2
	)

	traits = list(
		TRAIT_FORAGER,
		TRAIT_ORPHAN,
		TRAIT_BRUSHWALK,
		TRAIT_KNOWBANDITS
	)

/datum/job/advclass/forestguard/ruffian/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_STRENGTH, rand(-1, 1))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_INTELLIGENCE, rand(-2, 2))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_CONSTITUTION, rand(-1, 1))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_ENDURANCE, rand(-1, 1))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_FORTUNE, rand(-4, 4))

	add_verb(spawned, /mob/proc/haltyellorphan)

/datum/job/advclass/forestguard/rat
	title = "Forest Rat"
	tutorial = "Fed up with your antics in the city, you were rounded up by the city's Watch and put to work in the infamous forest garrison. \n\n Who knows, even despite your disadvantages, - you might just become more than a troublemaker."
	outfit = /datum/outfit/forestguard/ruffian
	category_tags = list(CTAG_FORGARRISON)
	allowed_races = list(SPEC_ID_KOBOLD, SPEC_ID_KOBOLD_FORMIKRAG)

	jobstats = list(
		STAT_PERCEPTION = 1
	)

	skills = list(
		/datum/attribute/skill/misc/swimming = 3,
		/datum/attribute/skill/misc/climbing = 4,
		/datum/attribute/skill/misc/athletics = 2,
		/datum/attribute/skill/craft/crafting = 2,
		/datum/attribute/skill/craft/carpentry = 1,
		/datum/attribute/skill/misc/sewing = 2,
		/datum/attribute/skill/labor/butchering = 2,
		/datum/attribute/skill/combat/bows = 1,
		/datum/attribute/skill/combat/crossbows = 1,
		/datum/attribute/skill/combat/knives = 2,
		/datum/attribute/skill/combat/axesmaces = 1,
		/datum/attribute/skill/combat/wrestling = 1,
		/datum/attribute/skill/craft/cooking = 2,
		/datum/attribute/skill/misc/sneaking = 2,
		/datum/attribute/skill/misc/stealing = 3,
		/datum/attribute/skill/craft/tanning = 2
	)

	traits = list(
		TRAIT_FORAGER,
		TRAIT_ORPHAN,
		TRAIT_BRUSHWALK,
		TRAIT_KNOWBANDITS
	)

/datum/job/advclass/forestguard/rat/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_STRENGTH, rand(-1, 1))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_INTELLIGENCE, rand(-2, 2))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_CONSTITUTION, rand(-1, 1))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_ENDURANCE, rand(-1, 1))
	spawned.adjust_stat_modifier(STATMOD_JOB, STAT_FORTUNE, rand(-4, 4))

	add_verb(spawned, /mob/proc/haltyellorphan)



/datum/outfit/forestguard/ruffian
	name = "Forest Ruffian"
	head = /obj/item/clothing/head/helmet/medium/decorated/rousskullmet
	neck = /obj/item/clothing/neck/highcollier
	shirt = /obj/item/clothing/shirt/undershirt/colored/black
	beltl = /obj/item/weapon/knife/dagger
	beltr = /obj/item/ammo_holder/quiver/arrows
	backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
	armor = /obj/item/clothing/armor/leather
	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/cooking/pan = 1,
		/obj/item/reagent_containers/food/snacks/egg = 1
	)

/mob/proc/haltyellorphan()
	set name = "HALT!"
	set category = "Emotes.Noises"
	emote("haltyellorphan")
