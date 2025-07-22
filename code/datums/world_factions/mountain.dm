/datum/world_faction/mountain_clans
	faction_name = "Dwarven Clans"
	desc = "Hardy dwarves from the mountain passes"
	faction_color = "#708090"

	essential_packs = list(
		/datum/supply_pack/tools/pick,
		/datum/supply_pack/tools/hammer,
		/datum/supply_pack/tools/tongs,
		/datum/supply_pack/rawmats/iron,
		/datum/supply_pack/rawmats/coal
	)

	common_pool = list(
		/datum/supply_pack/apparel/hatfur,
		/datum/supply_pack/apparel/leather_boots,
		/datum/supply_pack/apparel/workervest,
		/datum/supply_pack/apparel/leather_trousers,
		/datum/supply_pack/armor/leather_bracers,
		/datum/supply_pack/tools/shovel,
		/datum/supply_pack/tools/rope,
		/datum/supply_pack/food/meat,
		/datum/supply_pack/rawmats/copper,
		/datum/supply_pack/rawmats/tin,
		/datum/supply_pack/rawmats/lumber,
		/datum/supply_pack/rawmats/blocks
	)

	uncommon_pool = list(
		/datum/supply_pack/armor/gambeson,
		/datum/supply_pack/armor/chainmail_iron,
		/datum/supply_pack/weapons/axe,
		/datum/supply_pack/weapons/mace,
		/datum/supply_pack/weapons/shield,
		/datum/supply_pack/food/butterhair,
		/datum/supply_pack/food/stonebeard,
		/datum/supply_pack/instruments/mbox,
		/datum/supply_pack/rawmats/sinew
	)

	rare_pool = list(
		/datum/supply_pack/armor/cuirass_iron,
		/datum/supply_pack/armor/brigandine,
		/datum/supply_pack/weapons/greatsword,
		/datum/supply_pack/weapons/halberd,
		/datum/supply_pack/food/voddena,
		/datum/supply_pack/jewelry/circlet
	)

	exotic_pool = list(
		/datum/supply_pack/armor/coatofplates,
		/datum/supply_pack/armor/buckethelm,
		/datum/supply_pack/jewelry/goldring,
		/datum/supply_pack/rawmats/riddle_of_steel,
		/datum/supply_pack/luxury/talkstone
	)


/datum/world_faction/mountain_clans/initialize_faction_stock()
	..()
	// Mountain clans value tools and metalwork
	hard_value_multipliers[/obj/item/weapon/pick] = 1.3
	hard_value_multipliers[/obj/item/ingot] = 1.4
