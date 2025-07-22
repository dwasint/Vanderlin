/datum/world_faction/coastal_merchants
	faction_name = "Coastal Trade Union"
	desc = "Seafaring traders with exotic wares"
	faction_color = "#4682B4"
	essential_packs = list(
		/datum/supply_pack/tools/fishingrod,
		/datum/supply_pack/tools/bait,
		/datum/supply_pack/food/eel,
		/datum/supply_pack/apparel/undershirt_sailor,
		/datum/supply_pack/apparel/tights_sailor
	)
	common_pool = list(
		/datum/supply_pack/apparel/strawhat,
		/datum/supply_pack/apparel/undershirt_sailor_red,
		/datum/supply_pack/apparel/gladiator_sandals,
		/datum/supply_pack/apparel/hood,
		/datum/supply_pack/apparel/boots,
		/datum/supply_pack/apparel/shortboots,
		/datum/supply_pack/apparel/fingerl,
		/datum/supply_pack/food/carp,
		/datum/supply_pack/food/beer,
		/datum/supply_pack/tools/bottle,
		/datum/supply_pack/tools/alch_bottle,
		/datum/supply_pack/rawmats/glass,
		/datum/supply_pack/seeds/lime,
		/datum/supply_pack/seeds/lemon
	)
	uncommon_pool = list(
		/datum/supply_pack/apparel/spectacles,
		/datum/supply_pack/apparel/silkdress_random,
		/datum/supply_pack/apparel/tabard,
		/datum/supply_pack/apparel/halfcloak_random,
		/datum/supply_pack/apparel,  // Base apparel pack
		/datum/supply_pack/food/angler,
		/datum/supply_pack/food/winezaladin,
		/datum/supply_pack/food/winegrenzel,
		/datum/supply_pack/instruments/flute,
		/datum/supply_pack/instruments/harp,
		/datum/supply_pack/narcotics/perfume,
		/datum/supply_pack/seeds/tangerine
	)
	rare_pool = list(
		/datum/supply_pack/apparel/fancyhat,
		/datum/supply_pack/apparel/hennin,
		/datum/supply_pack/apparel/chaperon,
		/datum/supply_pack/food/clownfish,
		/datum/supply_pack/food/winevalorred,
		/datum/supply_pack/food/winevalorwhite,
		/datum/supply_pack/jewelry/silverring,
		/datum/supply_pack/luxury/spectacles_golden,
		/datum/supply_pack/seeds/pear,
		/datum/supply_pack/seeds/poppy
	)
	exotic_pool = list(
		/datum/supply_pack/food/elfred,
		/datum/supply_pack/food/elfblue,
		/datum/supply_pack/food/chocolate,
		/datum/supply_pack/jewelry/goldring,
		/datum/supply_pack/jewelry/gemcirclet,
		/datum/supply_pack/luxury/glassware_set,
		/datum/supply_pack/apparel/royaldyes,
		/datum/supply_pack/narcotics/moondust
	)

/datum/world_faction/coastal_merchants/initialize_faction_stock()
	..()
	// Coastal merchants prefer luxury items and reagents
	hard_value_multipliers[/obj/item/reagent_containers] = 1.2
	hard_value_multipliers[/obj/item/clothing/ring] = 1.3
