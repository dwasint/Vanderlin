/datum/preference/numeric/clientfps
	savefile_key = "clientfps"
	savefile_identifier = PREF_PLAYER
	category = "performance"
	can_randomize = FALSE
	should_update_preview = FALSE
	minimum = 0
	maximum = 1000
	step = 1

/datum/preference/numeric/clientfps/create_default_value()
	return 100
