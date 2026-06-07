/datum/preference/choiced/voice_type
	savefile_key = "voice_type"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/voice_type/init_possible_values(datum/preferences/prefs)
	return VOICE_TYPES_LIST

/datum/preference/choiced/voice_type/create_default_value()
	return VOICE_TYPE_MASC

/datum/preference/choiced/voice_type/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.voice_type = value
