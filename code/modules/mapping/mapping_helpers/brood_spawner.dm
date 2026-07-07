/datum/map_template/broodmother_entry
	width = 11
	height = 9

	id = "broodmother_entry"
	name = "Broodmother Sinkhole"
	mappath = "_maps/templates/broodmother_hole.dmm"

/obj/effect/broodmother_entry
	name = "broodmother_spawner"

/obj/effect/broodmother_entry/Initialize(mapload, ...)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(spawn_entry))

/obj/effect/broodmother_entry/proc/spawn_entry()
	var/turf/turf = get_turf(src)
	var/datum/map_template/template = new /datum/map_template/broodmother_entry()
	template.load(turf, TRUE)
	qdel(src)
