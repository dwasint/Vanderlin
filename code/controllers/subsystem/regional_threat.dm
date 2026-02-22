SUBSYSTEM_DEF(regionthreat)
	name = "Regional Threat"
	wait = 15 MINUTES
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	var/list/threat_regions = list()

/datum/controller/subsystem/regionthreat/Initialize(start_timeofday)
	for(var/datum/threat_region/region as anything in subtypesof(/datum/threat_region))
		if(IS_ABSTRACT(region))
			continue
		threat_regions += new region()
	return ..()

/datum/controller/subsystem/regionthreat/fire(resumed)
	var/player_count = GLOB.player_list.len
	var/ishighpop = player_count >= LOWPOP_THRESHOLD
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(ishighpop)
			TR.increase_latent_ambush(TR.highpop_tick)
		else
			TR.increase_latent_ambush(TR.lowpop_tick)

/datum/controller/subsystem/regionthreat/proc/get_region(region_name)
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(TR.region_name == region_name)
			return TR
	return null

/datum/threat_region_display
	var/region_name
	var/danger_level
	var/danger_color

/datum/controller/subsystem/regionthreat/proc/get_threat_regions_for_display()
	var/list/threat_region_displays = list()
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		var/datum/threat_region_display/TRS = new /datum/threat_region_display
		TRS.region_name = TR.region_name
		TRS.danger_level = TR.get_danger_level()
		TRS.danger_color = TR.get_danger_color()
		threat_region_displays += TRS
	return threat_region_displays
