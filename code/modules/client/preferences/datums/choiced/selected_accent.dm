/datum/preference/choiced/selected_accent
	savefile_key = "selected_accent"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	should_apply = FALSE

/datum/preference/choiced/selected_accent/init_possible_values(datum/preferences/prefs)
	return GLOB.accent_list

/datum/preference/choiced/selected_accent/create_default_value()
	return ACCENT_DEFAULT

/datum/preference/choiced/selected_accent/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.accent = value
