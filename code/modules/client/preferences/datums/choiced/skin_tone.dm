/datum/preference/choiced/skin_tone
	savefile_key = "skin_tone"
	savefile_identifier = PREF_CHARACTER
	category = "appearance"
	can_randomize = TRUE

/datum/preference/choiced/skin_tone/init_possible_values(datum/preferences/prefs)
	// Flatten the assoc list returned by get_skin_list() into a plain list of
	// skin-tone values (the right-hand side of each entry).
	var/datum/species/base_species = /datum/species/human/northern
	if(prefs)
		base_species = prefs.read_preference(/datum/preference/choiced/species)
	var/list/skins = list()
	var/datum/species/S = new base_species
	var/list/assoc = S.get_skin_list()
	for (var/k in assoc)
		skins |= assoc[k]
	qdel(S)
	return skins

/datum/preference/choiced/skin_tone/create_default_value()
	return SKIN_COLOR_CONTINENTAL

/datum/preference/choiced/skin_tone/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.skin_tone = value
	H.update_body()
