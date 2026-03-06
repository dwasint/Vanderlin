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
	return attributes?.adjust_experience(skill_type, amount, silent, check_apprentice)

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
	attributes?.adjust_skill_level(skill_type, delta, max_level, silent)

/**
 * Wipes all skill levels and XP back to zero.
 */
/mob/proc/purge_all_skills(silent = TRUE)
	attributes?.purge_all_skills(silent)

//
// These accept the OLD level values (0-6) and multiply by 10 internally.
// Use these when migrating call sites that still pass old-style values,
// e.g:  blade.adjust_skillrank(/datum/attribute/skill/combat/swords, 3, TRUE)
// becomes: blade.adjust_skillrank(/datum/attribute/skill/combat/swords, 3, TRUE)
// with no change at the call site - the helper does the conversion. it should NOT be used going forward

/**
 * LEGACY: Adjusts a skill by a delta in the old 0-6 scale.
 * Multiplies delta by 10 before applying.
 *
 * Example (unchanged call site):
 *   blade.adjust_skillrank(/datum/attribute/skill/combat/swords, 3, TRUE)
 *   -> internally calls adjust_skill_level(skill, 30, null, TRUE)
 */
/mob/proc/adjust_skillrank(skill_type, amt, silent = FALSE)
	attributes?.adjust_skill_level(skill_type, amt * 10, null, silent)
