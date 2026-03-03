/datum/job/prisoner
	title = "Prisoner"
	tutorial = "For a crime, or false allegation; as a hostage against another, \
	or held for ransom: your fate until this day has been ill-starred save its first. \
	Perhaps your story, which none but you recall, \
	will move some pity from callous hearts or promises of riches parole your release. \
	Maybe your old associates conspire now to release you in a daring rescue. \
	Yet it is far surer that your tears will rust this cursed mask \
	than the sun shine upon your face a freed soul once more."
	department_flag = PEASANTS
	display_order = JDO_PRISONER
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	faction = FACTION_TOWN
	total_positions = 0
	spawn_positions = 2
	can_random = FALSE
	banned_leprosy = FALSE
	bypass_lastclass = TRUE

	allowed_races = RACES_PLAYER_ALL

	outfit = /datum/outfit/prisoner

	cmode_music = 'sound/music/cmode/towner/CombatPrisoner.ogg'
	can_have_apprentices = FALSE
	antag_role = /datum/antagonist/prisoner

	jobstats = list(
		STAT_STRENGTH = -1,
		STAT_PERCEPTION = -1,
		STAT_INTELLIGENCE = -1,
		STAT_SPEED = -1,
		STAT_CONSTITUTION = -1,
		STAT_ENDURANCE = -1
	)

	skills = list(
		/datum/attribute/skill/combat/wrestling = 1,
		/datum/attribute/skill/combat/knives = 1,
		/datum/attribute/skill/combat/unarmed = 1,
		/datum/attribute/skill/misc/swimming = 2,
		/datum/attribute/skill/misc/athletics = 1,
		/datum/attribute/skill/misc/climbing = 2,
		/datum/attribute/skill/misc/sneaking = 3,
		/datum/attribute/skill/misc/lockpicking = 2,
	)

	traits = list(
		TRAIT_BANDITCAMP,
		TRAIT_NOBLE_BLOOD
	)

/datum/job/prisoner/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/prisonertype = "Commoner" //If you're Tiefling, Hollowkin, or Medicator, this is your only option.
	if(spawned.dna?.species?.id in RACES_PLAYER_FOREIGNNOBLE)
		prisonertype = browser_input_list(player_client, "What kind of prisoner are you?", "Filthy Criminal", list("Noble", "Commoner"))
	if(prisonertype == "Noble")
		SStreasury.create_bank_account(spawned, 173)
		spawned.adjust_skillrank(/datum/attribute/skill/combat/swords, 2, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/misc/reading, 2, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/misc/riding, 1, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/labor/mathematics, 3, TRUE)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_PERCEPTION, 3)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_INTELLIGENCE, 3)
		ADD_TRAIT(spawned, TRAIT_NOBLE_BLOOD, TRAIT_GENERIC)
	else
		spawned.adjust_skillrank(/datum/attribute/skill/combat/wrestling, 1, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/combat/knives, 1, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/misc/stealing, 3, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/misc/lockpicking, 1, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/misc/sewing, 2, TRUE) //so they're slightly better at the three things they can do while incarcerated.
		spawned.adjust_skillrank(/datum/attribute/skill/labor/farming, 2, TRUE)
		spawned.adjust_skillrank(/datum/attribute/skill/labor/fishing, 2, TRUE)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_SPEED, 2)
		spawned.adjust_stat_modifier(STATMOD_JOB, STAT_ENDURANCE, 2)
	if(spawned.wear_mask)
		var/obj/I = spawned.wear_mask
		spawned.dropItemToGround(spawned.wear_mask, TRUE)
		qdel(I)

/datum/outfit/prisoner
	name = "Prisoner"
	pants = /obj/item/clothing/pants/loincloth/colored/brown
	mask = /obj/item/clothing/face/facemask/prisoner
