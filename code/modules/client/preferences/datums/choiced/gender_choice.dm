/datum/preference/choiced/gender_choice
	savefile_key = "gender_choice"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE

/datum/preference/choiced/gender_choice/init_possible_values(datum/preferences/prefs)
	return list(ANY_GENDER, MALE, FEMALE)

/datum/preference/choiced/gender_choice/create_default_value()
	return ANY_GENDER

/datum/preference/choiced/gender_choice/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.gender_choice_pref = value
