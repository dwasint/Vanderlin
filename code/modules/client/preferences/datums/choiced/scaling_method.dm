/datum/preference/choiced/scaling_method
	savefile_key = "scaling_method"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/scaling_method/init_possible_values(datum/preferences/prefs)
	return list("normal", "pixel_perfect", "distorted")

/datum/preference/choiced/scaling_method/create_default_value()
	return "normal"
