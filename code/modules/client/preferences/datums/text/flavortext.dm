/datum/preference/text/flavortext
	savefile_key = "flavortext"
	savefile_identifier = PREF_CHARACTER
	category = "character_ooc"
	can_randomize = FALSE
	maximum_value_length = 1024
	should_update_preview = FALSE

/datum/preference/text/flavortext/deserialize(input, datum/preferences/prefs)
	return STRIP_HTML_SIMPLE(html_decode(input), maximum_value_length)

/datum/preference/text/flavortext/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.flavortext = value
