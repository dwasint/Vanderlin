/datum/cave_biome
	var/name = "Generic Cave"
	var/list/terrain_weights = list()
	var/list/flora_weights = list()
	var/list/feature_templates = list()
	var/flora_density = 0.08
	var/list/temperature_map
	var/list/moisture_map

	var/list/fauna_types = list() //! Populated on New()
	var/fauna_density = 3
	var/difficulty = 0

	var/list/ore_types_upper = list()
	var/list/ore_types_lower = list()  // List of ore types for lower level
	var/ore_vein_density = 10          // Minimum distance between ore vein centers
	var/ore_spread_iterations = 4      // How many times to spread from seed points

/datum/cave_biome/New(_difficulty)
	. = ..()
	difficulty = _difficulty
	setup_spawn_rules()
	setup_ores()

/datum/cave_biome/proc/setup_ores()
	ore_types_upper = list(
		"iron" = list(
			"turf" = /turf/closed/mineral/iron,
			"spread_chance" = 60,  // Not used, kept for reference
			"spread_range" = 2     // Actual cluster radius
		),
		"copper" = list(
			"turf" = /turf/closed/mineral/copper,
			"spread_chance" = 60,
			"spread_range" = 3
		),
		"coal" = list(
			"turf" = /turf/closed/mineral/coal,
			"spread_chance" = 60,
			"spread_range" = 2
		)
	)

	ore_types_lower = list(
		"gold" = list(
			"turf" = /turf/closed/mineral/gold,
			"spread_chance" = 50,
			"spread_range" = 2
		),
		"silver" = list(
			"turf" = /turf/closed/mineral/silver,
			"spread_chance" = 50,
			"spread_range" = 2
		),
		"gemeralds" = list(
			"turf" = /turf/closed/mineral/gemeralds,
			"spread_chance" = 50,
			"spread_range" = 2
		)
	)

/datum/cave_biome/proc/setup_spawn_rules()
	return

/datum/cave_biome/proc/select_terrain(temperature, moisture, level)
	return pickweight(terrain_weights)

/datum/cave_biome/proc/select_flora(temperature, moisture, level)
	if(!flora_weights.len)
		return null
	return pickweight(flora_weights)


/datum/cave_biome/mushroom
	name = "Mushroom Cave"
	terrain_weights = list(
		/turf/open/floor/naturalstone = 60,
		/turf/open/floor/cobblerock = 30,
		/turf/open/floor/volcanic = 10
	)
	flora_weights = list(
		/obj/structure/flora/shroom_tree = 40,
		/obj/structure/flora/grass/mushroom = 50,
	)
	feature_templates = list(
	)
	flora_density = 2

/datum/cave_biome/mushroom/setup_spawn_rules()
	. = ..()
	fauna_types = list(
		/mob/living/carbon/human/species/goblin/npc = new /datum/fauna_spawn_rule(
			min_temp = 0.4,
			max_temp = 0.9,
			min_moist = 0.2,
			max_moist = 0.8,
			min_h = 0,
			max_h = 1,
			weight = 100
		)
	)

/datum/cave_biome/mushroom/select_terrain(temperature, moisture, level)
	if(temperature > 0.7)
		if(prob(80))
			return /turf/open/floor/mushroom
		else
			return /turf/open/floor/mushroom/green

	if(temperature < 0.3)
		if(prob(70))
			return /turf/open/floor/naturalstone
		else
			return /turf/open/floor/mushroom/blue

	return pickweight(terrain_weights)

/datum/cave_biome/mushroom/select_flora(temperature, moisture, level)
	if(temperature < 0.7)
		if(prob(40))
			return /obj/structure/flora/shroom_tree
		if(prob(70))
			return /obj/structure/flora/grass/mushroom
	return null
