/proc/ticket_type_to_path(ticket_type)
	switch(ticket_type)
		if(TICKET_TYPE_LOADOUT)
			return /datum/ticket/loadout
		if(TICKET_TYPE_SPECIAL)
			return /datum/ticket/special
		if(TICKET_TYPE_JOB_BOOST)
			return /datum/ticket/job_boost
	return /datum/ticket

// Deserialise one savefile assoc-list entry into the right subtype.
/proc/ticket_from_list(list/L)
	if(!islist(L))
		return null
	var/subtype = ticket_type_to_path(L["ticket_type"])
	var/datum/ticket/t = new subtype()
	t.from_list(L)
	return t

/proc/generate_ticket_id()
	return "[time2text(world.realtime, "YYYYMMDD-hhmmss")]-[rand(1000,9999)]"

/// Find a ticket datum in a preferences list by ticket_id string.
/proc/find_ticket_in_prefs(datum/preferences/prefs, ticket_id)
	for(var/datum/ticket/t in prefs.owned_tickets)
		if(t.ticket_id == ticket_id)
			return t
	return null


/client/proc/test_ticket()
	admin_grant_ticket(ckey, TICKET_TYPE_SPECIAL, "Test", "testing desc.!", \
		special_trait_path = /datum/special_trait/black_biar)

/// Grant a ticket to a player by client reference.
/// Pass keyword args matching the target subtype's payload field.
/proc/admin_grant_ticket(
	target_ckey,
	ticket_type,
	name,
	description,
	granted_by = "server",
	grant_reason = "",
	loadout_item_path = null,
	special_trait_path = null,
	job_boost_job = null,
)
	var/subtype = ticket_type_to_path(ticket_type)
	var/datum/ticket/t = new subtype()
	t.ticket_id = generate_ticket_id()
	t.name = name
	t.description = description
	t.granted_by = granted_by
	t.granted_at = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	t.grant_reason = grant_reason

	// Assign payload to the correct subtype field
	switch(ticket_type)
		if(TICKET_TYPE_LOADOUT)
			var/datum/ticket/loadout/lt = t
			lt.loadout_item_path = loadout_item_path
		if(TICKET_TYPE_SPECIAL)
			var/datum/ticket/special/st = t
			st.special_trait_path = special_trait_path
		if(TICKET_TYPE_JOB_BOOST)
			var/datum/ticket/job_boost/jt = t
			jt.job_boost_job = job_boost_job

	// Online grant
	var/client/C = GLOB.directory[target_ckey]
	if(C?.prefs)
		C.prefs.owned_tickets += t
		C.prefs.save_character()
		to_chat(C, span_notice("You have received a ticket: <b>[name]</b>!"))
		log_game("TICKETS: [granted_by] granted '[name]' ([ticket_type]) to [target_ckey] (online). Reason: [grant_reason]")
		return TRUE

	// Offline grant — write directly to savefile
	var/target_file = file("data/player_saves/[target_ckey[1]]/[target_ckey]/preferences.sav")
	if(!fexists(target_file))
		log_game("TICKETS: Could not grant '[name]' to [target_ckey] — no savefile.")
		return FALSE
	var/savefile/S = new(target_file)
	var/list/raw
	S["owned_tickets"] >> raw
	if(!islist(raw))
		raw = list()
	raw += list(t.to_list())
	S["owned_tickets"] << raw
	log_game("TICKETS: [granted_by] granted '[name]' ([ticket_type]) to [target_ckey] (offline). Reason: [grant_reason]")
	return TRUE

/proc/use_ticket(client/user, datum/ticket/t)
	if(!user?.prefs || !(t in user.prefs.owned_tickets))
		return FALSE

	if(!t.use(user))
		return FALSE

	user.prefs.ticket_history += list(list(
		"event" = "used",
		"timestamp" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"),
		"ticket_id" = t.ticket_id,
		"name" = t.name,
		"type" = t.ticket_type,
	))
	user.prefs.owned_tickets -= t
	user.prefs.save_preferences()
	user.prefs.save_character()
	log_game("TICKETS: [user.ckey] used ticket '[t.name]' ([t.ticket_id]).")
	return TRUE
