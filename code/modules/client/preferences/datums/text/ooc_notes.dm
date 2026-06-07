/datum/preference/text/ooc_notes
	savefile_key = "ooc_notes"
	savefile_identifier = PREF_CHARACTER
	category = "character_ooc"
	can_randomize = FALSE
	maximum_value_length = 1024
	should_update_preview = FALSE

/datum/preference/text/ooc_notes/deserialize(input, datum/preferences/prefs)
	return STRIP_HTML_SIMPLE(html_decode(input), maximum_value_length)

/datum/preference/text/ooc_notes/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.ooc_notes = value
