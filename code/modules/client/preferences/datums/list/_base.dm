
/datum/preference/list
	abstract_type = /datum/preference/list
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/list/serialize(list/input)
	if (!islist(input))
		return list()
	return input.Copy()

/datum/preference/list/deserialize(list/input, datum/preferences/prefs)
	if (!islist(input))
		return create_default_value()
	return input.Copy()

/datum/preference/list/is_valid(value)
	return islist(value)

/datum/preference/list/create_default_value()
	return list()

/datum/preference/list/apply_to_human(mob/living/carbon/human/H, value)
	return
