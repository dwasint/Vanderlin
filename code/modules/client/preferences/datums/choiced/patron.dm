/datum/preference/choiced/patron
	savefile_key = "selected_patron"
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE

/datum/preference/choiced/patron/init_possible_values(datum/preferences/prefs)
	var/list/out = list()
	for (var/T in GLOB.patrons_by_type)
		out += T
	return out

/datum/preference/choiced/patron/create_default_value()
	return /datum/patron/divine/astrata // matches static/datum/patron/default_patron

/datum/preference/choiced/patron/serialize(input)
	if (istype(input, /datum/patron))
		var/datum/patron/patron = input
		return "[patron.type]"
	return "[input]"

/datum/preference/choiced/patron/deserialize(input, datum/preferences/prefs)
	var/path = ispath(input) ? input : text2path(input)
	if (!(path in GLOB.patrons_by_type))
		return create_default_value()
	return GLOB.patrons_by_type[path]

/datum/preference/choiced/patron/apply_to_human(mob/living/carbon/human/H, value, datum/preferences/prefs)
	H.set_patron(value)
