/datum/preference/choiced/phobia
	savefile_key = "phobia"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = TRUE

/datum/preference/choiced/phobia/init_possible_values(datum/preferences/prefs)
	return list("spiders")

/datum/preference/choiced/phobia/create_default_value()
	return "spiders"
