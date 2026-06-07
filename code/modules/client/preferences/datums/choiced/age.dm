/datum/preference/choiced/age
	savefile_key = "age"
	savefile_identifier = PREF_CHARACTER
	category = "character"

/datum/preference/choiced/age/init_possible_values(datum/preferences/prefs)
	// Pull valid ages from the character's current species, falling back to a
	// sane default list so we never crash with an empty choices list.
	return list(AGE_CHILD, AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)

/datum/preference/choiced/age/create_informed_default_value(datum/preferences/prefs)
	var/datum/species/S = prefs.pref_species
	if (S && S.possible_ages && S.possible_ages.len)
		return S.possible_ages[1]
	return AGE_ADULT

/datum/preference/choiced/age/deserialize(input, datum/preferences/prefs)
	// Ages are species-dependent; validate against the species' list if available.
	var/datum/species/S = prefs?.pref_species
	var/list/valid = (S && S.possible_ages && S.possible_ages.len) ? S.possible_ages : get_choices(prefs)
	return sanitize_inlist(input, valid, create_informed_default_value(prefs))

/datum/preference/choiced/age/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.age = value
