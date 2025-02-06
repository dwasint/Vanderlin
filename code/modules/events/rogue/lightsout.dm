/datum/round_event_control/rogue/lightsout
	name = "Lights Out"
	track = EVENT_TRACK_OMENS
	typepath = /datum/round_event/rogue/lightsout
	weight = 5
	max_occurrences = 1
	min_players = 0
	req_omen = TRUE
	todreq = list("dusk", "night")

/datum/round_event/rogue/lightsout
	announceWhen	= 1

/datum/round_event/rogue/lightsout/setup()
	return

/datum/round_event/rogue/lightsout/start()
	if(LAZYLEN(GLOB.fires_list))
		for(var/obj/i in GLOB.fires_list)
			i.extinguish()
	if(LAZYLEN(GLOB.streetlamp_list))
		for(var/obj/machinery/light/roguestreet/i in GLOB.streetlamp_list)
			i.lights_out()
	return
