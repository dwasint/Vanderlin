/datum/map_mob_stock/wyrmwood
	map_name = "Wyrmwood"
	stock = list(
		/mob/living/carbon/human/species/deadite = 120 //this can be raised in the future pathfinding costs fuck this hard
	)
	wave_defense_set_ids = list(
		"south-wyrm",
		"north-wyrm",
		"east-wyrm",
		"west-wyrm",
	)
	wave_defense_enabled = TRUE
	wave_mob_count_low = 12
	wave_mob_count_high = 20
