///how many tiles out from a client we still bother processing mobs that aren't otherwise exempt
#define MOB_PROCESSING_TILE_RANGE 15

SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list())
	var/static/list/camera_players_by_zlevel[][] = list(list())
	var/static/list/cubemonkeys = list()
	var/datum/mob_affix_system/affix_system
	///z-levels that should always fully process regardless of proximity to a client (e.g. town hubs)
	var/list/town_z = list()
	///whether we've already looked up town_z this round
	var/looked_for_town_z = FALSE
	///associative list of atom -> TRUE, built once per fire from cells near clients. used to skip far-away non-exempt mobs
	var/list/active_mobs = list()

/datum/controller/subsystem/mobs/stat_entry()
	..("P:[GLOB.mob_living_list.len - SSmatthios_mobs.matthios_mobs.len - SSisland_mobs.island_mobs.len]")

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()
		camera_players_by_zlevel.len++
		camera_players_by_zlevel[camera_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/proc/MaxZDec()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
		camera_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len > world.maxz)
		clients_by_zlevel.len--
		dead_players_by_zlevel.len--
		camera_players_by_zlevel.len--

/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1

	if(!looked_for_town_z)
		town_z = SSmapping.levels_by_trait(ZTRAIT_TOWN)
		looked_for_town_z = TRUE

	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()
		// exclude mobs handled by other subsystems
		src.currentrun -= SSmatthios_mobs.matthios_mobs
		src.currentrun -= SSisland_mobs.island_mobs
		active_mobs = build_active_mobs()

	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	while(currentrun.len)
		var/mob/living/L = currentrun[currentrun.len]
		currentrun.len--
		if(!L || QDELETED(L))
			GLOB.mob_living_list.Remove(L)
			continue

		if(!should_process(L))
			continue

		if(L.stat == DEAD)
			L.DeadLife(seconds, times_fired)
		else
			L.Life(seconds, times_fired)
		if (MC_TICK_CHECK)
			return

///returns TRUE if this mob should be processed this fire
/datum/controller/subsystem/mobs/proc/should_process(mob/living/L)
	if(L.client)
		return TRUE

	if((L.z in town_z))
		return TRUE

	return active_mobs[L]

///builds an associative list of every hearing-sensitive atom within MOB_PROCESSING_TILE_RANGE tiles of any client, across every z-level that currently has one.
///skips town z-levels since mobs there always process anyway regardless of this list
/datum/controller/subsystem/mobs/proc/build_active_mobs()
	. = list()
	var/list/seen_cells = list()
	for(var/z_index in 1 to clients_by_zlevel.len)
		if(z_index in town_z)
			continue //everything here processes unconditionally, no need to build cells for it
		var/list/clients_here = clients_by_zlevel[z_index]
		if(!length(clients_here))
			continue
		for(var/mob/living/client_mob as anything in clients_here)
			for(var/datum/spatial_grid_cell/cell as anything in SSspatial_grid.get_cells_in_range(client_mob, MOB_PROCESSING_TILE_RANGE))
				if(seen_cells[cell])
					continue
				seen_cells[cell] = TRUE
				for(var/atom/hearable as anything in cell.hearing_contents)
					.[hearable] = TRUE

/datum/controller/subsystem/mobs/proc/enhance_mob(mob/living/mob, delve_level = 1)
	if(!affix_system)
		affix_system = new()
	affix_system.enhance_mob(mob, delve_level - 1)

#undef MOB_PROCESSING_TILE_RANGE
