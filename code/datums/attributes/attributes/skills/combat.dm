/datum/attribute/skill/combat
	category = SKILL_CATEGORY_MELEE

/**
 * Returns the parry stamina modifier for this combat skill at the given level.
 * Level is a raw skill value (0-60). Scales linearly through tiers.
 */
/datum/attribute/skill/combat/proc/get_skill_parry_modifier(level)
	if(isnull(level) || level < 10)
		return 0      // untrained
	if(level < 20)
		return 5      // novice
	if(level < 30)
		return 10     // apprentice
	if(level < 40)
		return 15     // journeyman
	if(level < 50)
		return 20     // expert
	if(level < 60)
		return 25     // master
	return 35         // legendary

/datum/attribute/skill/combat/knives
	name = "Knife-fighting"
	desc = "Represents your character's ability to fight with knives and short blades. The higher your skill in Knife-fighting, the more accurate you'll be with knives and the better you'll be at parrying with them."
	governing_attribute = STAT_SPEED
	default_attributes = list(
		STAT_SPEED = -5,
		STAT_PERCEPTION = -6,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/combat/swords
	name = "Sword-fighting"
	desc = "Represents your character's ability to fight with swords and long blades. The higher your skill in Sword-fighting, the more accurate you'll be with swords and the better you'll be at parrying with them."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_SPEED = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/combat/polearms
	name = "Polearms"
	desc = "Represents your character's ability to fight with polearms and spears. The higher your skill in Polearms, the more accurate you'll be with polearms and the better you'll be at parrying with them."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_ENDURANCE = -7,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/combat/axesmaces
	name = "Axes & Maces"
	desc = "Represents your character's ability to fight with axes and maces. The higher your skill in Axes & Maces, the more accurate you'll be with axes and maces and the better you'll be at parrying with them."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_ENDURANCE = -7,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/combat/whipsflails
	name = "Whips & Flails"
	desc = "Represents your character's ability to fight with whips and flails. The higher your skill in Whips & Flails, the more accurate you'll be with whips and flails and the better you'll be at parrying with them."
	governing_attribute = STAT_SPEED
	default_attributes = list(
		STAT_SPEED = -7,
		STAT_PERCEPTION = -8,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/combat/bows
	name = "Archery"
	desc = "Represents your character's ability to fight with bows and arrows. The higher your skill in Archery, the more accurate you'll be with bows."
	category = SKILL_CATEGORY_RANGED
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -5,
		STAT_STRENGTH = -7,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/combat/crossbows
	name = "Crossbows"
	desc = "Represents your character's ability to fight with crossbows. The higher your skill in Crossbows, the more accurate you'll be with crossbows."
	category = SKILL_CATEGORY_RANGED
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -5,
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/combat/firearms
	name = "Firearms"
	desc = "Represents your character's ability to fight with firearms. The higher your skill in Firearms, the more accurate you'll be with firearms."
	category = SKILL_CATEGORY_RANGED
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -5,
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/combat/wrestling
	name = "Wrestling"
	desc = "Represents your character's ability to grab and wrestle people. The higher your skill in Wrestling, the harder it will be to escape your grabs."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_ENDURANCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/combat/unarmed
	name = "Fist-fighting"
	desc = "Represents your character's ability to fight unarmed. The higher your skill in Fist-fighting, the more accurate you'll be with your fists and the better you'll be at parrying."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -4,
		STAT_ENDURANCE = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/combat/shields
	name = "Shields"
	desc = "Represents your character's ability to defend yourself with shields. The higher your skill in Shields, the easier it will be to block with them."
	category = SKILL_CATEGORY_BLOCKING
	governing_attribute = STAT_ENDURANCE
	default_attributes = list(
		STAT_ENDURANCE = -4,
		STAT_STRENGTH = -6,
	)
	difficulty = SKILL_DIFFICULTY_EASY
