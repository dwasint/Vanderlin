/datum/attribute/skill/craft
	category = SKILL_CATEGORY_ENGINEERING

/datum/attribute/skill/craft/crafting
	name = "Crafting"
	desc = "A general skill that represents your character's ability to craft items. The higher your skill in Crafting, the more complex items you can craft."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -4,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/craft/weaponsmithing
	name = "Weaponsmithing"
	desc = "Represents your character's ability to craft metal weapons. The higher your skill in Weaponsmithing, the more complex weapons you can create, and the better the resulting quality, up to Masterwork."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		/datum/attribute/skill/craft/blacksmithing = -5,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/craft/armorsmithing
	name = "Armorsmithing"
	desc = "Represents your character's ability to craft metal armor. The higher your skill in Armorsmithing, the more complex armor you can create, and the better the resulting quality, up to Masterwork."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		/datum/attribute/skill/craft/blacksmithing = -5,
	)
	difficulty = SKILL_DIFFICULTY_HARD

/datum/attribute/skill/craft/blacksmithing
	name = "Blacksmithing"
	desc = "Represents your character's ability to craft metal items. The higher your skill in Blacksmithing, the more complex items you can create, and the better the resulting quality, up to Masterwork."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -5,
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/craft/smelting
	name = "Smelting"
	desc = "Represents your character's ability to smelt metal into ingots. The higher your skill in Smelting, the better the ingots you create, which affect the quality of the resulting item."
	governing_attribute = STAT_ENDURANCE
	default_attributes = list(
		STAT_ENDURANCE = -4,
		STAT_INTELLIGENCE = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/craft/carpentry
	name = "Carpentry"
	desc = "Represents your character's ability to craft wooden items. The higher your skill in Carpentry, the faster you can create wooden items and buildings."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -4,
		STAT_INTELLIGENCE = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/craft/masonry
	name = "Masonry"
	desc = "Represents your character's ability to craft stone items. The higher your skill in Masonry, the faster you can make stone items and buildings."
	governing_attribute = STAT_STRENGTH
	default_attributes = list(
		STAT_STRENGTH = -4,
		STAT_ENDURANCE = -5,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/craft/traps
	name = "Trapping"
	desc = "Represents your character's ability to lay traps. The higher your skill in Trapping, the more effective your traps will be and the less likely you are to set them off accidentally."
	category = SKILL_CATEGORY_SKULDUGGERY
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -5,
		STAT_INTELLIGENCE = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE

/datum/attribute/skill/craft/cooking
	name = "Cooking"
	desc = "Represents your character's ability to cook food. The higher your skill in Cooking, the better the food you can cook and the more you can make with your ingredients."
	category = SKILL_CATEGORY_DOMESTIC
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -4,
	)
	difficulty = SKILL_DIFFICULTY_EASY

/datum/attribute/skill/craft/alchemy
	name = "Alchemy"
	desc = "Represents your character's ability to craft potions. The higher your skill in Alchemy, the better you can identify potions and ingredients."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -7,
	)
	difficulty = SKILL_DIFFICULTY_VERY_HARD

/**
 * Grants or removes TRAIT_LEGENDARY_ALCHEMIST based on skill level.
 * Threshold is >= 50 (master tier). Call from wherever attribute changes are detected.
 */
/datum/attribute/skill/craft/alchemy/proc/on_level_change(mob/owner, new_level)
	if(new_level >= 50)
		ADD_TRAIT(owner, TRAIT_LEGENDARY_ALCHEMIST, type)
	else
		REMOVE_TRAIT(owner, TRAIT_LEGENDARY_ALCHEMIST, type)

/datum/attribute/skill/craft/bombs
	name = "Bombcrafting"
	desc = "Represents your character's ability to craft bombs. The higher your skill in Bombcrafting, the better the bombs you can create and the more you can make with your materials."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		/datum/attribute/skill/craft/alchemy = -6,
	)
	difficulty = SKILL_DIFFICULTY_VERY_HARD

/datum/attribute/skill/craft/engineering
	name = "Engineering"
	desc = "Represents your character's ability to craft mechanical items. The higher your skill in Engineering, the more complex items you can create without failure."
	governing_attribute = STAT_INTELLIGENCE
	default_attributes = list(
		STAT_INTELLIGENCE = -7,
	)
	difficulty = SKILL_DIFFICULTY_VERY_HARD

/datum/attribute/skill/craft/tanning
	name = "Skincrafting"
	desc = "Represents your character's ability to process and use animal hide. The higher your skill in Skincrafting, the more leather you can create and the more you can make with it."
	governing_attribute = STAT_PERCEPTION
	default_attributes = list(
		STAT_PERCEPTION = -5,
		STAT_STRENGTH = -6,
	)
	difficulty = SKILL_DIFFICULTY_AVERAGE
