
/datum/ticket/job_boost
	ticket_type = TICKET_TYPE_JOB_BOOST
	var/job_boost_job

/datum/ticket/job_boost/to_list()
	var/list/L = ..()
	L["job_boost_job"] = job_boost_job
	return L

/datum/ticket/job_boost/from_list(list/L)
	..()
	job_boost_job = L["job_boost_job"]

/datum/ticket/job_boost/enrich_ui_entry(list/entry)
	entry["ui_icon"] = null
	entry["ui_icon_state"] = null
	entry["ui_fa_icon"] = "briefcase"
	entry["ui_color"] = "#ff9800"
	entry["ui_type_label"] = "Job Boost"
	entry["ui_grant_summary"] = job_boost_job ? "Job boost: [job_boost_job]" : "Job boost"

/datum/ticket/job_boost/use(client/user)
	if(!job_boost_job)
		return FALSE
	to_chat(user, span_notice("Ticket used! Job boost applied: <b>[job_boost_job]</b>!"))
	return TRUE
