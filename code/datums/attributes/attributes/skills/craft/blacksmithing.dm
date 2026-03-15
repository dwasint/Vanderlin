/datum/attribute/skill/craft/blacksmithing
	name = "Blacksmithing"
	desc = "Represents your character's ability to craft metal items. The higher your skill in Blacksmithing, the more complex items you can create, and the better the resulting quality, up to Masterwork."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE
	dreams = list(
		"...CLANG! Clang! Clang... you feel the weight of the hammer reverberate up your arm, past your shoulder, through your spine... the hits march to the drums of your heart. you feel attuned to the metal."
	)

/datum/attribute/skill/craft/weaponsmithing
	name = "Weaponsmithing"
	desc = "Represents your character's ability to craft metal weapons. The higher your skill in Weaponsmithing, the more complex weapons you can create, and the better the resulting quality, up to Masterwork."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		/datum/attribute/skill/craft/blacksmithing = -5,
	)
	difficulty = SKILL_DIFFICULTY_HARD
	dreams = list(
		"...you gently grasp the tang of the blade. without water nor oil, you turn over to the basin, slicing your hand, and letting the blood fill the void... you quench the blade."
	)

/datum/attribute/skill/craft/armorsmithing
	name = "Armorsmithing"
	desc = "Represents your character's ability to craft metal armor. The higher your skill in Armorsmithing, the more complex armor you can create, and the better the resulting quality, up to Masterwork."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		/datum/attribute/skill/craft/blacksmithing = -5,
	)
	difficulty = SKILL_DIFFICULTY_HARD
	dreams = list(
		"...you are assailed by a faceless adversary. he pummels you - crack, crack, crack... it hurts, you scream... he tires, you do not..."
	)

