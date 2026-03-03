/datum/attribute/skill/labor
	category = SKILL_CATEGORY_DOMESTIC

/datum/attribute/skill/labor/mining
	name = "Mining"
	desc = "Represents your character's ability to mine. The higher your skill in Mining, the faster you can mine and the more materials you can get from veins."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -4,
		STAT_ENDURANCE = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/labor/farming
	name = "Farming"
	desc = "Represents your character's ability to farm. The higher your skill in Farming, the more you know about a seed, fertilizer, etc. by examining them."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -4,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/labor/taming
	name = "Taming"
	desc = "Represents your character's ability to tame animals. The higher your skill in Taming, the more dangerous animals you can tame and the more effective you will be at taming them."
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -6,
		STAT_FORTUNE = -7,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/labor/fishing
	name = "Fishing"
	desc = "Represents your character's ability to fish. The higher your skill in Fishing, the better the fish you can catch and the faster you can catch them."
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -4,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/labor/butchering
	name = "Butchering"
	desc = "Represents your character's ability to butcher animals. The higher your skill in Butchering, the more meat and materials you can get from animals."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -4,
		STAT_PERCEPTION = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/labor/lumberjacking
	name = "Lumberjacking"
	desc = "Represents your character's ability to chop down trees and split logs. The higher your skill in Lumberjacking, the more efficient you are at splitting logs."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -4,
		STAT_ENDURANCE = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/labor/mathematics
	name = "Mathematics"
	desc = "Represents your character's ability to do math. The higher your skill in Mathematics, the more complex math you can do and the faster you can do it."
	category = SKILL_CATEGORY_RESEARCH
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_HARD
