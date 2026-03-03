/mob/proc/ensure_attributes()
	RETURN_TYPE(/datum/attribute_holder)
	if(!attributes)
		attributes = new /datum/attribute_holder(src)
	return attributes

// ── Core XP proc ─────────────────────────────────────────────────────────────

/**
 * Awards XP toward a skill, converting it into level gains automatically.
 * This is the standard call site for in-game skill training.
 *
 * Arguments:
 *   skill_type       - typepath of the /datum/attribute/skill
 *   amount           - XP to award
 *   silent           - suppress level-up messages
 *   check_apprentice - share XP with nearby apprentices
 */
/mob/proc/adjust_experience(skill_type, amount, silent = FALSE, check_apprentice = TRUE)
	if(HAS_TRAIT(src, TRAIT_NO_EXPERIENCE))
		return FALSE
	return ensure_attributes().adjust_experience(skill_type, amount, silent, check_apprentice)

// ── New-system level helpers ──────────────────────────────────────────────────

/**
 * Returns the current raw level (0-60) of a skill.
 */
/mob/proc/get_skill_level(skill_type)
	return nulltozero(GET_MOB_ATTRIBUTE_VALUE_RAW(src, skill_type))

/**
 * Returns TRUE if the mob has any training in a skill (level > 0).
 */
/mob/proc/has_skill(skill_type)
	return get_skill_level(skill_type) > SKILL_LEVEL_NONE

/**
 * Sets a skill directly to a level (0-60), syncing the XP pool to match.
 *
 * Arguments:
 *   skill_type - typepath of the skill
 *   level      - target level in the new 0-60 range
 *   silent     - suppress messages
 */
/mob/proc/set_skill_level(skill_type, level, silent = TRUE)
	ensure_attributes().set_skill_level(skill_type, level, silent)

/**
 * Adjusts a skill by a delta in the new 0-60 range, with an optional cap.
 *
 * Arguments:
 *   skill_type - typepath of the skill
 *   delta      - levels to add or remove (e.g. +5, -10)
 *   max_level  - optional ceiling in 0-60 range; null = no cap
 *   silent     - suppress messages
 */
/mob/proc/adjust_skill_level(skill_type, delta, max_level = null, silent = FALSE)
	ensure_attributes().adjust_skill_level(skill_type, delta, max_level, silent)

/**
 * Wipes all skill levels and XP back to zero.
 */
/mob/proc/purge_all_skills(silent = TRUE)
	ensure_attributes().purge_all_skills(silent)

// ── Legacy compat helpers (old 0-6 scale input) ───────────────────────────────
//
// These accept the OLD level values (0-6) and multiply by 10 internally.
// Use these when migrating call sites that still pass old-style values,
// e.g:  blade.adjust_skillrank(/datum/attribute/skill/combat/swords, 3, TRUE)
// becomes: blade.adjust_skillrank(/datum/attribute/skill/combat/swords, 3, TRUE)
// with no change at the call site - the helper does the conversion.

/**
 * LEGACY: Adjusts a skill by a delta in the old 0-6 scale.
 * Multiplies delta by 10 before applying.
 *
 * Example (unchanged call site):
 *   blade.adjust_skillrank(/datum/attribute/skill/combat/swords, 3, TRUE)
 *   -> internally calls adjust_skill_level(skill, 30, null, TRUE)
 */
/mob/proc/adjust_skillrank(skill_type, amt, silent = FALSE)
	ensure_attributes().adjust_skill_level(skill_type, amt * 10, null, silent)

/**
 * LEGACY: Sets a skill to a level in the old 0-6 scale.
 * Multiplies level by 10 before applying.
 *
 * Example (unchanged call site):
 *   blade.set_skillrank(/datum/attribute/skill/combat/swords, 5)
 *   -> sets skill to level 50 (master)
 */
/mob/proc/set_skillrank(skill_type, level, silent = TRUE)
	ensure_attributes().set_skill_level(skill_type, level * 10, silent)

/**
 * LEGACY: Raises a skill by amt (old 0-6 scale) up to a maximum (old 0-6 scale).
 * Both amt and max are multiplied by 10 before applying.
 *
 * Example (unchanged call site):
 *   blade.clamped_adjust_skillrank(/datum/attribute/skill/combat/swords, 2, 4)
 *   -> raises skill by up to 20, capped at level 40 (expert)
 */
/mob/proc/clamped_adjust_skillrank(skill_type, amt, max, silent = FALSE)
	ensure_attributes().adjust_skill_level(skill_type, amt * 10, max * 10, silent)

/mob/proc/get_skill_exp_multiplier(skill_type)
	return ensure_attributes().get_skill_xp_multiplier(skill_type)

/mob/proc/set_skill_exp_multiplier(skill_type, multiplier)
	ensure_attributes().set_skill_xp_multiplier(skill_type, multiplier)

/mob/proc/adjust_skill_exp_multiplier(skill_type, amount)
	ensure_attributes().adjust_skill_xp_multiplier(skill_type, amount)

/mob/proc/remove_skill_exp_multiplier(skill_type)
	ensure_attributes().remove_skill_xp_multiplier(skill_type)

/**
 * Returns the raw XP accumulated toward a skill (useful for UI/debug).
 */
/mob/proc/get_skill_xp(skill_type)
	return ensure_attributes().get_skill_xp(skill_type)

/**
 * Returns the learning boon multiplier for a skill (age/trait modifier).
 * Multiply your XP grant by this if you want age to affect training speed.
 */
/mob/proc/get_learning_boon(skill_type)
	return ensure_attributes().get_learning_boon(skill_type)

/**
 * Prints all current skill levels to the mob's chat.
 */
/mob/proc/print_skill_levels()
	ensure_attributes().print_skills(src)
