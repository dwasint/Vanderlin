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
			var/is_gossip = istype(G, /datum/history/gossip)
			var/side_text = is_gossip ? G:heard_text : (mind == G.aggressor) ? G.aggressor_text : G.victim_text
			grudge_data += list(list(
				"label" = G.label,
				"text" = side_text,
				"is_gossip" = is_gossip,
				"say_string" = is_gossip ? "Did you hear that [R.snapshot?["name"] || "someone"] [G:heard_text]?" : null,
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

/datum/tgui_relations/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("say_gossip")
			var/text = params["text"]
			if(!istext(text) || !length(text))
				return FALSE
			// Sanitize length
			text = copytext(text, 1, 280)
			var/mob/living/M = ui.user
			if(!isliving(M))
				return FALSE
			M.say(text)
			return TRUE
