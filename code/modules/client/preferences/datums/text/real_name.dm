/datum/preference/text/real_name
	savefile_key = "real_name"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	priority = PREF_PRIORITY_NAMES
	can_randomize = TRUE
	maximum_value_length = MAX_NAME_LEN

/datum/preference/text/real_name/create_default_value()
	return "Unknown"

/datum/preference/text/real_name/deserialize(input, datum/preferences/prefs)
	var/cleaned = reject_bad_name(..())
	return cleaned || "Unknown"

/datum/preference/text/real_name/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.real_name = value
	H.name = value
