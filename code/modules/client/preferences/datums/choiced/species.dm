/datum/preference/choiced/species
	savefile_key = "species"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	priority = PREF_PRIORITY_SPECIES

/datum/preference/choiced/species/init_possible_values(datum/preferences/prefs)
	var/list/out = list()
	for (var/id in GLOB.species_list)
		out += GLOB.species_list[id]
	return out

/datum/preference/choiced/species/apply_to_client(client/C, value)
	C.prefs.pref_species = new value

/datum/preference/choiced/species/create_default_value()
	return /datum/species/human/northern

/datum/preference/choiced/species/serialize(input)
	if (ispath(input))
		var/datum/species/S = new input
		return S.id
	if (istype(input, /datum/species))
		var/datum/species/spec = input
		return spec.id
	return "[input]"

/datum/preference/choiced/species/deserialize(input, datum/preferences/prefs)
	var/species_type = GLOB.species_list[input]
	if (!species_type)
		species_type = /datum/species/human/northern
	return species_type

/datum/preference/choiced/species/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.set_species(value, FALSE, prefs)
