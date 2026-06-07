/datum/preference/color/voice_color
	savefile_key = "voice_color"
	savefile_identifier = PREF_CHARACTER
	category = "appearance"

/datum/preference/color/voice_color/create_default_value()
	return "a0a0a0"

/datum/preference/color/voice_color/deserialize(input, datum/preferences/prefs)
	return sanitize_hexcolor(input, include_crunch = FALSE)

/datum/preference/color/voice_color/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.voice_color = value
