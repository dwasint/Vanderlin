/datum/preference/choiced/domhand
	savefile_key = "domhand"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/domhand/init_possible_values(datum/preferences/prefs)
	return list(1, 2)

/datum/preference/choiced/domhand/create_default_value()
	return 2

/datum/preference/choiced/domhand/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.domhand = value
