GLOBAL_VAR_INIT(total_runtimes, GLOB.total_runtimes || 0)
GLOBAL_VAR_INIT(total_runtimes_skipped, 0)

#ifdef USE_CUSTOM_ERROR_HANDLER
#define ERROR_USEFUL_LEN 2

/world/Error(exception/E, datum/e_src)
	GLOB.total_runtimes++

	if(!istype(E)) //Something threw an unusual exception
		log_world("uncaught runtime error: [E]")
		return ..()

	//this is snowflake because of a byond bug (ID:2306577), do not attempt to call non-builtin procs in this if
	if(copytext(E.name,1,32) == "Maximum recursion level reached")
		//log to world while intentionally triggering the byond bug.
		log_world("runtime error: [E.name]\n[E.desc]")
		//if we got to here without silently ending, the byond bug has been fixed.
		log_world("The bug with recursion runtimes has been fixed. Please remove the snowflake check from world/Error in [__FILE__]:[__LINE__]")
		return //this will never happen.

	else if(copytext(E.name,1,18) == "Out of resources!")
		log_world("BYOND out of memory. Restarting")
		log_game("BYOND out of memory. Restarting")
		send_to_glitchtip(E, list("critical" = TRUE, "action" = "server_restart"))
		TgsEndProcess()
		Reboot(reason = 1)
		return ..()

	if (islist(stack_trace_storage))
		for (var/line in splittext(E.desc, "\n"))
			if (text2ascii(line) != 32)
				stack_trace_storage += line

	var/static/list/error_last_seen = list()
	var/static/list/error_cooldown = list() /* Error_cooldown items will either be positive(cooldown time) or negative(silenced error)
												If negative, starts at -1, and goes down by 1 each time that error gets skipped*/

	if(!error_last_seen) // A runtime is occurring too early in start-up initialization
		return ..()

	var/erroruid = "[E.file][E.line]"
	var/last_seen = error_last_seen[erroruid]
	var/cooldown = error_cooldown[erroruid] || 0

	if(last_seen == null)
		error_last_seen[erroruid] = world.time
		last_seen = world.time

	if(cooldown < 0)
		error_cooldown[erroruid]-- //Used to keep track of skip count for this error
		GLOB.total_runtimes_skipped++
		return //Error is currently silenced, skip handling it
	//Handle cooldowns and silencing spammy errors
	var/silencing = FALSE

	// We can runtime before config is initialized because BYOND initialize objs/map before a bunch of other stuff happens.
	// This is a bunch of workaround code for that. Hooray!
	var/configured_error_cooldown
	var/configured_error_limit
	var/configured_error_silence_time
	if(config && config.entries)
		configured_error_cooldown = CONFIG_GET(number/error_cooldown)
		configured_error_limit = CONFIG_GET(number/error_limit)
		configured_error_silence_time = CONFIG_GET(number/error_silence_time)
	else
		var/datum/config_entry/CE = /datum/config_entry/number/error_cooldown
		configured_error_cooldown = initial(CE.config_entry_value)
		CE = /datum/config_entry/number/error_limit
		configured_error_limit = initial(CE.config_entry_value)
		CE = /datum/config_entry/number/error_silence_time
		configured_error_silence_time = initial(CE.config_entry_value)


	//Each occurence of a unique error adds to its cooldown time...
	cooldown = max(0, cooldown - (world.time - last_seen)) + configured_error_cooldown
	// ... which is used to silence an error if it occurs too often, too fast
	if(cooldown > configured_error_cooldown * configured_error_limit)
		cooldown = -1
		silencing = TRUE
		spawn(0)
			usr = null
			sleep(configured_error_silence_time)
			var/skipcount = abs(error_cooldown[erroruid]) - 1
			error_cooldown[erroruid] = 0
			if(skipcount > 0)
				SEND_TEXT(world.log, "\[[time_stamp()]] Skipped [skipcount] runtimes in [E.file],[E.line].")
				send_to_glitchtip(E, list(
					"skip_count" = skipcount,
					"silenced" = TRUE,
					"silence_duration" = configured_error_silence_time
				))
				GLOB.error_cache.log_error(E, skip_count = skipcount)

	error_last_seen[erroruid] = world.time
	error_cooldown[erroruid] = cooldown

	var/list/usrinfo = null
	var/locinfo
	if(istype(usr))
		usrinfo = list("  usr: [key_name(usr)]")
		locinfo = loc_name(usr)
		if(locinfo)
			usrinfo += "  usr.loc: [locinfo]"
	// The proceeding mess will almost definitely break if error messages are ever changed
	var/list/splitlines = splittext(E.desc, "\n")
	var/list/desclines = list()
	if(LAZYLEN(splitlines) > ERROR_USEFUL_LEN) // If there aren't at least three lines, there's no info
		for(var/line in splitlines)
			if(LAZYLEN(line) < 3 || findtext(line, "source file:") || findtext(line, "usr.loc:"))
				continue
			if(findtext(line, "usr:"))
				if(usrinfo)
					desclines.Add(usrinfo)
					usrinfo = null
				continue // Our usr info is better, replace it

			if(copytext(line, 1, 3) != "  ")
				desclines += ("  " + line) // Pad any unpadded lines, so they look pretty
			else
				desclines += line
	if(usrinfo) //If this info isn't null, it hasn't been added yet
		desclines.Add(usrinfo)
	if(silencing)
		desclines += "  (This error will now be silenced for [DisplayTimeText(configured_error_silence_time)])"
	if(GLOB.error_cache)
		GLOB.error_cache.log_error(E, desclines)

	var/list/glitchtip_extra = list()
	glitchtip_extra["cooldown"] = cooldown
	glitchtip_extra["total_runtimes"] = GLOB.total_runtimes
	glitchtip_extra["total_runtimes_skipped"] = GLOB.total_runtimes_skipped
	glitchtip_extra["description_lines"] = desclines

	if(silencing)
		glitchtip_extra["will_be_silenced"] = TRUE
		glitchtip_extra["silence_duration"] = configured_error_silence_time
	send_to_glitchtip(E, glitchtip_extra)

	var/main_line = "\[[time_stamp()]] Runtime in [E.file],[E.line]: [E]"
	SEND_TEXT(world.log, main_line)
	for(var/line in desclines)
		SEND_TEXT(world.log, line)

#ifdef UNIT_TESTS
	if(GLOB.current_test)
		//good day, sir
		GLOB.current_test.Fail("[main_line]\n[desclines.Join("\n")]")
#endif


	// This writes the regular format (unwrapping newlines and inserting timestamps as needed).
	log_runtime("runtime error: [E.name]\n[E.desc]")
	add_elastic_data_immediate(ELASCAT_RUNTIMES, list(
		"name" = E.name,
		"desc" = E.desc,
		"file" = "[E.file || "unknown"]",
		"line" = E.line,
	))
#endif

#undef ERROR_USEFUL_LEN

/datum/config_entry/string/glitchtip_dsn
	config_entry_value = ""

/datum/config_entry/string/glitchtip_environment
	config_entry_value = "production"

/datum/config_entry/flag/glitchtip_enabled

/proc/generate_simple_uuid()
	var/uuid = ""
	for(var/i = 1 to 32)
		uuid += pick("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
		if(i == 8 || i == 12 || i == 16 || i == 20)
			uuid += "-"
	return uuid

/proc/send_to_glitchtip(exception/E, list/extra_data = null)
	if(!CONFIG_GET(flag/glitchtip_enabled) || !CONFIG_GET(string/glitchtip_dsn))
		return

	var/glitchtip_dsn = CONFIG_GET(string/glitchtip_dsn)

	//! Parse DSN to extract components
	//! Format: https://key@host/project_id
	var/dsn_clean = replacetext(glitchtip_dsn, "https://", "")
	var/at_pos = findtext(dsn_clean, "@")
	var/slash_pos = findtext(dsn_clean, "/", at_pos)

	if(!at_pos || !slash_pos)
		log_runtime("Invalid Glitchtip DSN format")
		return

	var/key = copytext(dsn_clean, 1, at_pos)
	var/host = copytext(dsn_clean, at_pos + 1, slash_pos)
	var/project_id = copytext(dsn_clean, slash_pos + 1)

	// Build Glitchtip/Sentry event payload
	var/list/event_data = list()
	event_data["event_id"] = generate_simple_uuid()
	event_data["timestamp"] = time_stamp_metric()
	event_data["level"] = "error"
	event_data["platform"] = "other"
	event_data["server_name"] = world.name
	event_data["environment"] = CONFIG_GET(string/glitchtip_environment)

	//! SDK information
	event_data["sdk"] = list(
		"name" = "byond-glitchtip",
		"version" = "1.0.0"
	)

	//! Exception data - Glitchtip expects this format
	var/list/exception_data = list()
	exception_data["type"] = "BYOND Runtime Error"
	exception_data["value"] = E.name
	exception_data["module"] = E.file

	// Parse stack trace from BYOND error description
	var/list/frames = list()
	var/list/stack_lines = splittext(E.desc, "\n")
	var/current_proc = "unknown"

	for(var/line in stack_lines)
		line = trim(line)
		if(!line || length(line) < 3)
			continue

		// Extract procedure name
		if(findtext(line, "proc name:"))
			current_proc = copytext(line, findtext(line, ":") + 2)
			continue

		// Extract source file info
		if(findtext(line, "source file:"))
			var/file_info = copytext(line, findtext(line, ":") + 2)
			var/comma_pos = findtext(file_info, ",")
			if(comma_pos)
				var/filename = copytext(file_info, 1, comma_pos)
				var/line_num = text2num(copytext(file_info, comma_pos + 1))

				var/list/frame = list()
				frame["filename"] = filename
				frame["lineno"] = line_num || E.line
				frame["function"] = current_proc
				frame["in_app"] = TRUE
				frames += list(frame)

	// If no frames parsed, create a basic one
	if(!length(frames))
		var/list/frame = list()
		frame["filename"] = E.file
		frame["lineno"] = E.line
		frame["function"] = "unknown"
		frame["in_app"] = TRUE
		frames += list(frame)

	exception_data["stacktrace"] = list("frames" = frames)
	event_data["exception"] = list("values" = list(exception_data))

	// User context
	if(istype(usr))
		var/list/user_data = list()
		user_data["id"] = usr.key
		user_data["username"] = usr.name
		if(usr.client)
			user_data["ip_address"] = usr.client.address
		event_data["user"] = user_data

		// Add location context
		var/locinfo = loc_name(usr)
		if(locinfo)
			if(!extra_data)
				extra_data = list()
			extra_data["user_location"] = locinfo

	if(extra_data)
		event_data["extra"] = extra_data

	// Tags for filtering in Glitchtip
	event_data["tags"] = list(
		"server" = world.name,
		"file" = E.file,
		"line" = "[E.line]",
		"byond_version" = world.byond_version
	)

	event_data["fingerprint"] = list("[E.file]:[E.line]", E.name)

	send_glitchtip_request(event_data, host, project_id, key)

/proc/send_glitchtip_request(list/event_data, host, project_id, key)
	var/glitchtip_url = "https://[host]/api/[project_id]/store/"
	var/json_payload = json_encode(event_data)

	//! Glitchtip/Sentry auth header - According to docs this needs to be like this
	var/auth_header = "Sentry sentry_version=7, sentry_client=byond-glitchtip/1.0.0, sentry_key=[key], sentry_timestamp=[time_stamp_metric()]"

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, glitchtip_url, json_payload, list(
		"X-Sentry-Auth" = auth_header,
		"Content-Type" = "application/json",
		"User-Agent" = "byond-glitchtip/1.0.0"
	))
	request.begin_async()
