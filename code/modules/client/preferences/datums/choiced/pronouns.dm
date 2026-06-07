/datum/preference/choiced/pronouns
	savefile_key = "pronouns"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/pronouns/init_possible_values(datum/preferences/prefs)
	return list(HE_HIM, SHE_HER, THEY_THEM, IT_ITS)

/datum/preference/choiced/pronouns/create_default_value()
	return HE_HIM

/datum/preference/choiced/pronouns/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.pronouns = value
