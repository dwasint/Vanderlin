/datum/preference/text/setspouse
	savefile_key = "setspouse"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	maximum_value_length = MAX_NAME_LEN

/datum/preference/text/setspouse/create_default_value()
	return ""

/datum/preference/text/setspouse/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.setspouse = value
