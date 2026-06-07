/datum/preference/choiced/gender
	savefile_key = "gender"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	priority = PREF_PRIORITY_GENDER

/datum/preference/choiced/gender/init_possible_values(datum/preferences/prefs)
	return list(MALE, FEMALE, PLURAL)

/datum/preference/choiced/gender/create_default_value()
	return MALE

/datum/preference/choiced/gender/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.gender = value
