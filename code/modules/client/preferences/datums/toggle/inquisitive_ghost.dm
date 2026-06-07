/datum/preference/toggle/inquisitive_ghost
	savefile_key = "inquisitive_ghost"
	savefile_identifier = PREF_PLAYER
	category = "ghost"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/datum/preference/toggle/inquisitive_ghost/apply_to_client(client/C, value)
	C.prefs.inquisitive_ghost = value
