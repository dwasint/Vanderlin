/datum/preference/numeric/ui_scale
	savefile_key = "ui_scale"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	minimum = 50
	maximum = 200
	step = 5

/datum/preference/numeric/ui_scale/create_default_value()
	return 100
