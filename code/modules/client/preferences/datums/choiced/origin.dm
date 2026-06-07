/datum/preference/choiced/origin
	savefile_key = "origin"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/origin/init_possible_values(datum/preferences/prefs)
	return list("Default")

/datum/preference/choiced/origin/create_default_value()
	return "Default"
