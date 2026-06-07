/datum/preference/choiced/culture
	savefile_key = "culture"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/culture/init_possible_values(datum/preferences/prefs)
	// Returns a list of typepath strings for all /datum/culture subtypes.
	var/list/out = list()
	for (var/datum/culture/T as anything in subtypesof(/datum/culture))
		if (IS_ABSTRACT(T))
			continue
		out += T
	return out

/datum/preference/choiced/culture/create_default_value()
	return /datum/culture/universal/ambiguous

/datum/preference/choiced/culture/serialize(input)
	return "[input]" // typepath -> string

/datum/preference/choiced/culture/deserialize(input, datum/preferences/prefs)
	var/path = text2path(input)
	return sanitize_inlist(path, get_choices(), create_default_value())

/datum/preference/choiced/culture/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.culture = value
