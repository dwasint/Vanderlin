/datum/attribute/skill/magic
	category = SKILL_CATEGORY_RESEARCH
	difficulty = SKILL_DIFFICULTY_VERY_HARD

/datum/attribute/skill/magic/holy
	name = "Miracles"
	desc = "Represents your character's ability to perform divine magic. The higher your skill in Miracles, the more powerful your divine magic will be."
	governing_attribute = STAT_FORTUNE
	default_attributes = list(
		STAT_FORTUNE = -8,
	)

/datum/attribute/skill/magic/blood
	name = "Blood Sorcery"
	desc = "Represents your character's ability to perform blood magic. The higher your skill in Blood Sorcery, the more powerful your blood magic will be."
	governing_attribute = STAT_CONSTITUTION
	default_attributes = list(
		STAT_CONSTITUTION = -8,
	)

/datum/attribute/skill/magic/arcane
	name = "Arcyne Magic"
	desc = "Represents your character's ability to perform arcyne magic. The higher your skill in Arcyne Magic, the more powerful your arcyne magic will be and you'll have access to more spells."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -8,
	)
	// NOTE: Grant 1 spell point per tier crossed (every 10 levels).

/datum/attribute/skill/magic/druidic
	name = "Druidic Trickery"
	desc = "Represents your character's ability to perform druidic magic. The higher your skill in Druidic Trickery, the more powerful your druidic magic will be."
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -8,
		STAT_FORTUNE = -9,
	)
