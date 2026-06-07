/datum/preference/numeric/max_chat_length
	savefile_key = "max_chat_length"
	savefile_identifier = PREF_PLAYER
	category = "chat"
	can_randomize = FALSE
	should_update_preview = FALSE
	minimum = 1
	maximum = CHAT_MESSAGE_MAX_LENGTH
	step = 1

/datum/preference/numeric/max_chat_length/create_default_value()
	return CHAT_MESSAGE_MAX_LENGTH
