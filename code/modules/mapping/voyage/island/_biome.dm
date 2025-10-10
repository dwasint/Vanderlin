/datum/island_biome
	var/name = "Generic Biome"
	var/list/terrain_weights = list()
	var/list/flora_weights = list()
	var/list/feature_templates = list()
	var/list/beach_flora_weights = list(
		/obj/structure/flora/driftwood = 20,
		/obj/structure/flora/starfish = 10,
		/obj/structure/flora/shells = 30,
	)
	var/flora_density = 2
	var/beach_flora_density = 2
	var/turf/beach_turf = /turf/open/floor/sand
	var/max_height = 3
	var/list/temperature_map
	var/list/moisture_map

	var/list/fauna_types = list() //! Populated on New()
	var/fauna_density = 3

/datum/island_biome/proc/select_terrain(temperature, moisture, height)
	return pickweight(terrain_weights)

/datum/island_biome/proc/select_flora(temperature, moisture, height)
	return pickweight(flora_weights)

/datum/island_biome/proc/select_patch_flora(temperature, moisture, height)
	return pickweight(flora_weights)

/datum/island_biome/proc/select_beach_flora(temperature, moisture, height)
	return pickweight(beach_flora_weights)
