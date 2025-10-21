
/datum/unit_test/outfit_skill_levels/Run()
	var/max_individual_skill = 4  // Maximum skill level for any single skill
	var/max_total_skills = 10     // Maximum total skill points across all skills

	var/list/allowed_skilled_outfits = list(
	)

	for(var/outfit_type in subtypesof(/datum/outfit))
		// Skip allowed outfits
		if(outfit_type in allowed_skilled_outfits)
			continue

		var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)

		// Equip the outfit
		dummy.equipOutfit(outfit_type, TRUE)

		var/total_skill_points = 0

		// Check all skill types
		for(var/skill_path in subtypesof(/datum/skill))
			var/skill_level = dummy.get_skill_level(skill_path)
			total_skill_points += skill_level

			if(skill_level > max_individual_skill)
				TEST_FAIL("[outfit_type] has skill [skill_path] at level [skill_level], exceeding maximum of [max_individual_skill]")

		if(total_skill_points > max_total_skills)
			TEST_FAIL("[outfit_type] has total skill points of [total_skill_points], exceeding maximum of [max_total_skills]")
		dummy.purge_all_skills()
