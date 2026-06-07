/datum/preference/choiced/alignment
	savefile_key = "alignment"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/alignment/init_possible_values(datum/preferences/prefs)
	return ALL_ALIGNMENTS_LIST // Replace with your actual alignment list.

/datum/preference/choiced/alignment/create_default_value()
	return ALIGNMENT_TN
