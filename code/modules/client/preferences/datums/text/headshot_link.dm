/datum/preference/text/headshot_link
	savefile_key = "headshot_link"
	savefile_identifier = PREF_CHARACTER
	category = "character_ooc"
	can_randomize = FALSE
	maximum_value_length = 512
	should_update_preview = FALSE

/datum/preference/text/headshot_link/is_valid(value, datum/preferences/prefs)
	// Empty string is always valid (no headshot set).
	if (!length(value))
		return TRUE
	return ..() && is_valid_headshot_link(null, value, TRUE)


/datum/preference/text/headshot_link/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.headshot_link = value
