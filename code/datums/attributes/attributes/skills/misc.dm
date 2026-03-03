/datum/attribute/skill/misc
	category = SKILL_CATEGORY_GENERAL

/datum/attribute/skill/misc/athletics
	name = "Athletics"
	desc = "A general skill that represents your character's physical fitness. The higher your skill in Athletics, the higher your stamina and energy."
	governing_attribute = STAT_ENDURANCE
	default_attributes = list(
		STAT_ENDURANCE = -4,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/misc/climbing
	name = "Climbing"
	desc = "Represents your character's ability to scale walls and trees. The higher your skill in Climbing, the faster you can climb and the less damage you'll take while falling."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_ENDURANCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/misc/reading
	name = "Reading"
	desc = "Represents your character's ability to read and write. Without at least some skill in Reading, you'll be totally unable to read or write."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -8,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/misc/swimming
	name = "Swimming"
	desc = "Represents your character's ability to swim. The higher your skill in Swimming, the faster you can swim and the less energy you'll use."
	governing_attribute = STAT_ENDURANCE
	default_attributes = list(
		STAT_ENDURANCE = -5,
		STAT_STRENGTH = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/misc/stealing
	name = "Pickpocketing"
	desc = "Represents your character's ability to steal from others. The higher your skill in Pickpocketing, the more likely you are to succeed and the less likely you are to be caught."
	category = SKILL_CATEGORY_SKULDUGGERY
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -6,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/misc/sneaking
	name = "Sneaking"
	desc = "Represents your character's ability to move quietly and unseen. The higher your skill in Sneaking, the better you can hide in shadows."
	category = SKILL_CATEGORY_SKULDUGGERY
	governing_attribute = STAT_SPEED
	default_attributes = list(
		STAT_SPEED = -5,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/misc/lockpicking
	name = "Lockpicking"
	desc = "Represents your character's ability to pick locks. The higher your skill in Lockpicking, the more easily you can pick locks, and the less likely you are to break your tools."
	category = SKILL_CATEGORY_SKULDUGGERY
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -7,
		STAT_INTELLIGENCE = -7,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/misc/riding
	name = "Riding"
	desc = "Represents your character's ability to ride animals. The higher your skill in Riding, the less likely you are to be thrown off your mount."
	governing_attribute = STAT_ENDURANCE
	default_attributes = list(
		STAT_ENDURANCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/misc/music
	name = "Music"
	desc = "Represents your character's ability to play musical instruments. The higher your skill in Music, the better you can play. Bards can use higher skills for better effects!"
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -7,
		STAT_PERCEPTION = -8,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/misc/medicine
	name = "Medicine"
	desc = "Represents your character's ability to perform medicine on others. The higher your skill in Medicine, the better you can treat your patients and the faster you can perform surgery."
	category = SKILL_CATEGORY_MEDICAL
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/misc/sewing
	name = "Sewing"
	desc = "Represents your character's ability to sew. The higher your skill in Sewing, the more complex items you can create, and the faster you can sew."
	category = SKILL_CATEGORY_DOMESTIC
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -5,
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_EASY
