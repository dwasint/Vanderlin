/datum/preference/text/family
	savefile_key = "family"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	maximum_value_length = MAX_NAME_LEN

/datum/preference/text/family/create_default_value()
	return FAMILY_NONE

/datum/preference/text/family/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.familytree_pref = value
