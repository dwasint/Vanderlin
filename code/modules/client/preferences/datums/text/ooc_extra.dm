/datum/preference/text/ooc_extra
	savefile_key = "ooc_extra"
	savefile_identifier = PREF_CHARACTER
	category = "character_ooc"
	can_randomize = FALSE
	maximum_value_length = 512
	should_update_preview = FALSE

/datum/preference/text/ooc_extra/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.ooc_extra = value
