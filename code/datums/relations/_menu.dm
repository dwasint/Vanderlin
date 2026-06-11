/datum/tgui_relations
	var/datum/mind/mind

/datum/tgui_relations/New(datum/mind/M)
	mind = M

/datum/tgui_relations/ui_host(mob/user)
	return user

/datum/tgui_relations/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_relations/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "Relations", "Relations")
		ui.open()

/datum/tgui_relations/ui_data(mob/user)
	var/list/rel_list = list()
	for(var/datum/relation/R in mind.relations)
		if(!R.snapshot)
			continue
		var/list/grudge_data = list()
		for(var/datum/history/G in R.relation_history)
			var/side_text = (mind == G.aggressor) ? G.aggressor_text : G.victim_text
			grudge_data += list(list(
				"label" = G.label,
				"text" = side_text,
			))
		rel_list += list(list(
			"name" = R.other?.name,
			"rel_type" = R.name,
			"snapshot" = R.snapshot?.Copy(),
			"desc" = R.desc,
			"grudges" = grudge_data,
			"is_asymmetric" = !R.symmetric,
		))
	//header bar count
	var/rival_count = 0
	for(var/datum/relation/R in mind.relations)
		if(istype(R, /datum/relation/rival))
			rival_count++
	var/rival_pref = 1
	if(mind.current?.client?.prefs)
		rival_pref = mind.current.client.prefs.read_preference(/datum/preference/numeric/rival_count)
	return list(
		"relations" = rel_list,
		"rival_count" = rival_count,
		"rival_pref" = rival_pref,
	)
