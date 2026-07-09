/datum/attribute_holder/sheet/job/goblin/hell
	attribute_variance = list(
		STAT_STRENGTH = list(2, 6),
		STAT_PERCEPTION = list(-5, 0),
		STAT_INTELLIGENCE = list(-9, -6),
		STAT_CONSTITUTION = list(0, 4),
		STAT_ENDURANCE = list(-2, 2),
		STAT_SPEED = list(-6, 0),
	)
	raw_attribute_list = list(
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/swords = 10,
	)

/datum/species/goblin/hell
	name = "hell goblin"
	id = "goblin_hell"
	raceicon = "goblin_hell"
	statsheet_male = /datum/attribute_holder/sheet/job/goblin/hell
