/mob/living/proc/has_taboo(tattoo_name)
	if (!tattoo_name)
		return
	for (var/tattoo in taboos)
		var/datum/taboo_tattoo/CT = taboos[tattoo]
		if (CT.name == tattoo_name)
			return CT
	return null

/datum/taboo_tattoo
	var/name = "taboo"
	var/desc = ""
	var/tier = 0//1, 2 or 3
	var/datum/bodypart_feature/feature
	var/mob/bearer = null
	var/blood_cost = 0
