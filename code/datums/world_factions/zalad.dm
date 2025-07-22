
/datum/world_faction/zalad_traders
	faction_name = "Zalad Traders"
	desc = "Nomadic traders from the harsh desert regions"
	faction_color = "#D2691E"
	essential_packs = list(
		/datum/supply_pack/apparel/backpack,
		/datum/supply_pack/apparel/satchel,
		/datum/supply_pack/apparel/pouch,
		/datum/supply_pack/tools/rope,
		/datum/supply_pack/food/water,
		/datum/supply_pack/food/hardtack,
		/datum/supply_pack/apparel/leather_belt,
		/datum/supply_pack/tools/sack
	)
	common_pool = list(
		/datum/supply_pack/apparel/headband,
		/datum/supply_pack/apparel/sandals,
		/datum/supply_pack/apparel/undershirt_random,
		/datum/supply_pack/apparel/tights_random,
		/datum/supply_pack/apparel/simpleshoes,
		/datum/supply_pack/apparel/shortshirt_random,
		/datum/supply_pack/apparel/tunic_random,
		/datum/supply_pack/food/meat,
		/datum/supply_pack/food/cheese,
		/datum/supply_pack/tools/candles,
		/datum/supply_pack/tools/flint,
		/datum/supply_pack/tools/bottle,
		/datum/supply_pack/rawmats/cloth,
		/datum/supply_pack/seeds/onion,
		/datum/supply_pack/seeds/potato
	)
	uncommon_pool = list(
		/datum/supply_pack/apparel/raincloak_random,
		/datum/supply_pack/apparel/leather_gloves,
		/datum/supply_pack/apparel/black_leather_belt,
		/datum/supply_pack/apparel/raincloak_furcloak_brown,
		/datum/supply_pack/apparel/dress_gen_random,
		/datum/supply_pack/armor/leather_armor,
		/datum/supply_pack/weapons/huntingknife,
		/datum/supply_pack/weapons/dagger,
		/datum/supply_pack/food/beer,
		/datum/supply_pack/tools/lamptern,
		/datum/supply_pack/rawmats/feather,
		/datum/supply_pack/seeds/berry,
		/datum/supply_pack/instruments/drum
	)
	rare_pool = list(
		/datum/supply_pack/apparel/silkdress_random,
		/datum/supply_pack/apparel/shepherd,
		/datum/supply_pack/apparel/robe,
		/datum/supply_pack/apparel/armordress,
		/datum/supply_pack/armor/studleather,
		/datum/supply_pack/weapons/spear,
		/datum/supply_pack/weapons/bow,
		/datum/supply_pack/food/spottedhen,
		/datum/supply_pack/rawmats/silk,
		/datum/supply_pack/seeds/sunflowers
	)
	exotic_pool = list(
		/datum/supply_pack/apparel/silkcoat,
		/datum/supply_pack/apparel/menacing,
		/datum/supply_pack/apparel/bardhat,
		/datum/supply_pack/jewelry/silverring,
		/datum/supply_pack/food/chocolate,
		/datum/supply_pack/narcotics/spice,
		/datum/supply_pack/seeds/sugarcane,
		/datum/supply_pack/luxury/merctoken
	)

/datum/world_faction/zalad_traders/initialize_faction_stock()
	..()
	hard_value_multipliers[/obj/item/reagent_containers/food] = 1.3
	hard_value_multipliers[/obj/item/clothing/armor] = 1.2
