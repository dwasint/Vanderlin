/obj/effect/mob_spawn/human/dwarf
	mob_species = /datum/species/dwarf/mountain
/obj/effect/mob_spawn/human/dwarf/trader
	outfit = /datum/outfit/job/tailor

/datum/world_faction/mountain_clans
	faction_name = "Dwarven Clans"
	desc = "Hardy dwarves from the mountain passes"
	faction_color = "#708090"
	trader_outfits = list(
		/obj/effect/mob_spawn/human/dwarf/trader
	)
	trader_type_weights = list(
		/datum/trader_data/luxury_merchant = 5,
		/datum/trader_data/food_merchant = 12,
		/datum/trader_data/alchemist = 7,
		/datum/trader_data/material_merchant = 20,
		/datum/trader_data/clothing_merchant = 10,
		/datum/trader_data/tool_merchant = 25,
	)
	essential_packs = list(
		/datum/supply_pack/tools/pick,
		/datum/supply_pack/tools/hammer,
		/datum/supply_pack/tools/tongs,
		/datum/supply_pack/rawmats/iron,
		/datum/supply_pack/rawmats/coal
	)
	common_pool = list(
		// Armor - Heavy focus on practical protective gear
		/datum/supply_pack/armor/skullcap,
		/datum/supply_pack/armor/minerhelmet,
		/datum/supply_pack/armor/poth,
		/datum/supply_pack/armor/nasalh,
		/datum/supply_pack/armor/chaincoif_iron,
		/datum/supply_pack/armor/bracers,
		/datum/supply_pack/armor/chain_gloves_iron,
		/datum/supply_pack/armor/chainlegs_iron,
		/datum/supply_pack/armor/chainkilt_iron,
		/datum/supply_pack/armor/light_armor_boots,
		// Apparel
		/datum/supply_pack/apparel/hatfur,
		/datum/supply_pack/apparel/leather_boots,
		/datum/supply_pack/apparel/workervest,
		/datum/supply_pack/apparel/leather_trousers,
		/datum/supply_pack/apparel/knitcap,
		/datum/supply_pack/apparel/coif,
		/datum/supply_pack/apparel/apron_brown,
		/datum/supply_pack/apparel/black_leather_gloves,
		/datum/supply_pack/armor/leather_bracers,
		// Tools - Core dwarven crafting tools
		/datum/supply_pack/tools/shovel,
		/datum/supply_pack/tools/rope,
		/datum/supply_pack/tools/chain,
		/datum/supply_pack/tools/Sickle,
		/datum/supply_pack/tools/pitchfork,
		/datum/supply_pack/tools/hoe,
		/datum/supply_pack/tools/thresher,
		/datum/supply_pack/tools/plough,
		/datum/supply_pack/tools/bucket,
		// Food - Hearty dwarven fare
		/datum/supply_pack/food/meat,
		/datum/supply_pack/food/blackgoat,
		/datum/supply_pack/food/potato,
		/datum/supply_pack/food/wheat,
		/datum/supply_pack/food/egg,
		/datum/supply_pack/food/butter,
		// Materials
		/datum/supply_pack/rawmats/copper,
		/datum/supply_pack/rawmats/tin,
		/datum/supply_pack/rawmats/lumber,
		/datum/supply_pack/rawmats/blocks,
		/datum/supply_pack/rawmats/ash
	)
	uncommon_pool = list(
		// Better armor
		/datum/supply_pack/armor/gambeson,
		/datum/supply_pack/armor/chainmail_iron,
		/datum/supply_pack/armor/chaincoif_steel,
		/datum/supply_pack/armor/chainlegs_steel,
		/datum/supply_pack/armor/chainkilt_steel,
		/datum/supply_pack/armor/angle_gloves,
		/datum/supply_pack/armor/steel_boots,
		// Apparel
		/datum/supply_pack/apparel/leather_vest_random,
		/datum/supply_pack/apparel/trousers,
		// Weapons - Dwarven combat gear
		/datum/supply_pack/weapons/axe,
		/datum/supply_pack/weapons/mace,
		/datum/supply_pack/weapons/smace,
		/datum/supply_pack/weapons/shortsword,
		/datum/supply_pack/weapons/sword_iron,
		/datum/supply_pack/weapons/shield,
		/datum/supply_pack/weapons/towershield,
		// Food & Drink
		/datum/supply_pack/food/butterhair,
		/datum/supply_pack/food/stonebeard,
		/datum/supply_pack/food/grenzelbeer,
		/datum/supply_pack/food/salami,
		// Instruments
		/datum/supply_pack/instruments/mbox,
		/datum/supply_pack/instruments/vocals,
		// Materials
		/datum/supply_pack/rawmats/sinew
	)
	rare_pool = list(
		// High-end armor
		/datum/supply_pack/armor/cuirass_iron,
		/datum/supply_pack/armor/brigandine,
		/datum/supply_pack/armor/cuirass,
		/datum/supply_pack/armor/plate_gloves,
		/datum/supply_pack/armor/sallet,
		/datum/supply_pack/armor/hounskull,
		// Apparel
		/datum/supply_pack/apparel/ridingboots,
		// Weapons
		/datum/supply_pack/weapons/greatsword,
		/datum/supply_pack/weapons/halberd,
		/datum/supply_pack/weapons/sword,
		/datum/supply_pack/weapons/greatmace,
		/datum/supply_pack/weapons/flail,
		// Food & Luxury
		/datum/supply_pack/food/voddena,
		/datum/supply_pack/jewelry/circlet,
		/datum/supply_pack/luxury/silver_plaque_belt
	)
	exotic_pool = list(
		/datum/supply_pack/armor/coatofplates,
		/datum/supply_pack/armor/buckethelm,
		/datum/supply_pack/armor/visorsallet,
		/datum/supply_pack/jewelry/goldring,
		/datum/supply_pack/rawmats/riddle_of_steel,
		/datum/supply_pack/luxury/talkstone,
		/datum/supply_pack/luxury/gold_plaque_belt
	)

/datum/world_faction/mountain_clans/initialize_faction_stock()
	..()
	// Mountain clans value tools and metalwork
	hard_value_multipliers[/obj/item/weapon/pick] = 1.3
	hard_value_multipliers[/obj/item/ingot] = 1.4

/datum/world_faction/zalad_traders
	faction_name = "Zalad Traders"
	desc = "Nomadic traders from the harsh desert regions"
	faction_color = "#D2691E"
	trader_type_weights = list(
		/datum/trader_data/luxury_merchant = 10,
		/datum/trader_data/food_merchant = 5,
		/datum/trader_data/alchemist = 25,
		/datum/trader_data/material_merchant = 12,
		/datum/trader_data/clothing_merchant = 20,
		/datum/trader_data/tool_merchant = 10,
	)
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
		// Light armor for desert travel
		/datum/supply_pack/armor/imask,
		/datum/supply_pack/armor/smask,
		// Apparel suited for desert nomads
		/datum/supply_pack/apparel/headband,
		/datum/supply_pack/apparel/sandals,
		/datum/supply_pack/apparel/undershirt_random,
		/datum/supply_pack/apparel/tights_random,
		/datum/supply_pack/apparel/simpleshoes,
		/datum/supply_pack/apparel/shortshirt_random,
		/datum/supply_pack/apparel/tunic_random,
		// Food essentials
		/datum/supply_pack/food/meat,
		/datum/supply_pack/food/cheese,
		/datum/supply_pack/food/pepper,
		/datum/supply_pack/food/honey,
		/datum/supply_pack/food/cutlery,
		// Tools for survival
		/datum/supply_pack/tools/candles,
		/datum/supply_pack/tools/flint,
		/datum/supply_pack/tools/bottle,
		/datum/supply_pack/tools/needle,
		/datum/supply_pack/tools/scroll,
		/datum/supply_pack/tools/parchment,
		/datum/supply_pack/tools/sleepingbag,
		/datum/supply_pack/tools/keyrings,
		// Materials
		/datum/supply_pack/rawmats/cloth,
		// Seeds for cultivation
		/datum/supply_pack/seeds/onion,
		/datum/supply_pack/seeds/potato,
		/datum/supply_pack/seeds/spelt,
		/datum/supply_pack/seeds/cabbage,
		/datum/supply_pack/seeds/turnip
	)
	uncommon_pool = list(
		// Better armor
		/datum/supply_pack/armor/studleather_masterwork,
		/datum/supply_pack/armor/chainmail_hauberk,
		// Apparel
		/datum/supply_pack/apparel/raincloak_random,
		/datum/supply_pack/apparel/leather_gloves,
		/datum/supply_pack/apparel/black_leather_belt,
		/datum/supply_pack/apparel/raincloak_furcloak_brown,
		/datum/supply_pack/apparel/dress_gen_random,
		/datum/supply_pack/armor/leather_armor,
		// Weapons
		/datum/supply_pack/weapons/huntingknife,
		/datum/supply_pack/weapons/dagger,
		/datum/supply_pack/weapons/sdagger,
		/datum/supply_pack/weapons/whip,
		/datum/supply_pack/weapons/sflail,
		// Food & Drink
		/datum/supply_pack/food/beer,
		/datum/supply_pack/food/onin,
		// Tools
		/datum/supply_pack/tools/lamptern,
		/datum/supply_pack/tools/dyebin,
		/datum/supply_pack/tools/lockpicks,
		// Materials & Seeds
		/datum/supply_pack/rawmats/feather,
		/datum/supply_pack/seeds/berry,
		/datum/supply_pack/seeds/weed,
		/datum/supply_pack/seeds/sleaf,
		// Instruments
		/datum/supply_pack/instruments/drum,
		/datum/supply_pack/instruments/lute,
		// Narcotics/Trade goods
		/datum/supply_pack/narcotics/sigs,
		/datum/supply_pack/narcotics/zigbox,
		/datum/supply_pack/narcotics/soap
	)
	rare_pool = list(
		// Apparel
		/datum/supply_pack/apparel/silkdress_random,
		/datum/supply_pack/apparel/shepherd,
		/datum/supply_pack/apparel/robe,
		/datum/supply_pack/apparel/armordress,
		/datum/supply_pack/armor/studleather,
		// Weapons
		/datum/supply_pack/weapons/spear,
		/datum/supply_pack/weapons/bow,
		/datum/supply_pack/weapons/saxe,
		/datum/supply_pack/weapons/crossbow,
		/datum/supply_pack/weapons/quivers,
		/datum/supply_pack/weapons/arrowquiver,
		// Food
		/datum/supply_pack/food/spottedhen,
		// Materials
		/datum/supply_pack/rawmats/silk,
		// Seeds
		/datum/supply_pack/seeds/sunflowers,
		/datum/supply_pack/seeds/plum,
		/datum/supply_pack/seeds/strawberry,
		// Narcotics
		/datum/supply_pack/narcotics/ozium,
		/datum/supply_pack/narcotics/poison
	)
	exotic_pool = list(
		/datum/supply_pack/apparel/silkcoat,
		/datum/supply_pack/apparel/menacing,
		/datum/supply_pack/apparel/bardhat,
		/datum/supply_pack/jewelry/silverring,
		/datum/supply_pack/food/chocolate,
		/datum/supply_pack/narcotics/spice,
		/datum/supply_pack/narcotics/spoison,
		/datum/supply_pack/seeds/sugarcane,
		/datum/supply_pack/luxury/merctoken,
		/datum/supply_pack/narcotics/zigboxempt
	)

/datum/world_faction/zalad_traders/initialize_faction_stock()
	..()
	hard_value_multipliers[/obj/item/reagent_containers/food] = 1.3
	hard_value_multipliers[/obj/item/clothing/armor] = 1.2

/obj/effect/mob_spawn/human/demi
	mob_species = /datum/species/demihuman
/obj/effect/mob_spawn/human/demi/trader
	outfit = /datum/outfit/job/tailor
/obj/effect/mob_spawn/human/elf
	mob_species = /datum/species/elf/snow
/obj/effect/mob_spawn/human/elf/trader
	outfit = /datum/outfit/job/tailor

/datum/world_faction/coastal_merchants
	faction_name = "Coastal Trade Union"
	desc = "Seafaring traders with exotic wares"
	faction_color = "#4682B4"
	trader_outfits = list(
		/obj/effect/mob_spawn/human/demi/trader,
		/obj/effect/mob_spawn/human/elf/trader
	)
	trader_type_weights = list(
		/datum/trader_data/luxury_merchant = 25,
		/datum/trader_data/food_merchant = 20,
		/datum/trader_data/alchemist = 15,
		/datum/trader_data/material_merchant = 12,
		/datum/trader_data/clothing_merchant = 10,
		/datum/trader_data/tool_merchant = 5,
	)
	essential_packs = list(
		/datum/supply_pack/tools/fishingrod,
		/datum/supply_pack/tools/bait,
		/datum/supply_pack/food/eel,
		/datum/supply_pack/apparel/undershirt_sailor,
		/datum/supply_pack/apparel/tights_sailor
	)
	common_pool = list(
		// Apparel suited for coastal life
		/datum/supply_pack/apparel/strawhat,
		/datum/supply_pack/apparel/undershirt_sailor_red,
		/datum/supply_pack/apparel/gladiator_sandals,
		/datum/supply_pack/apparel/hood,
		/datum/supply_pack/apparel/boots,
		/datum/supply_pack/apparel/shortboots,
		/datum/supply_pack/apparel/fingerless_gloves,
		// Seafood and coastal cuisine
		/datum/supply_pack/food/carp,
		/datum/supply_pack/food/beer,
		/datum/supply_pack/food/elfbeer,
		/datum/supply_pack/food/elfcab,
		// Tools for maritime trade
		/datum/supply_pack/tools/bottle,
		/datum/supply_pack/tools/alch_bottle,
		/datum/supply_pack/tools/alch_bottles,
		/datum/supply_pack/tools/fryingpan,
		/datum/supply_pack/tools/pot,
		/datum/supply_pack/tools/wpipe,
		/datum/supply_pack/tools/fishingline,
		/datum/supply_pack/tools/fishinghook,
		// Materials
		/datum/supply_pack/rawmats/glass,
		// Seeds for coastal cultivation
		/datum/supply_pack/seeds/lime,
		/datum/supply_pack/seeds/lemon,
		/datum/supply_pack/seeds/apple,
		/datum/supply_pack/seeds/blackberry,
		/datum/supply_pack/seeds/rasberry,
		// Livestock - coastal communities
		/datum/supply_pack/livestock/chicken,
		/datum/supply_pack/livestock/cat
	)
	uncommon_pool = list(
		// Refined apparel
		/datum/supply_pack/apparel/spectacles,
		/datum/supply_pack/apparel/silkdress_random,
		/datum/supply_pack/apparel/tabard,
		/datum/supply_pack/apparel/halfcloak_random,
		// Exotic foods
		/datum/supply_pack/food/angler,
		/datum/supply_pack/food/winezaladin,
		/datum/supply_pack/food/winegrenzel,
		// Musical instruments - coastal culture
		/datum/supply_pack/instruments/flute,
		/datum/supply_pack/instruments/harp,
		/datum/supply_pack/instruments/guitar,
		/datum/supply_pack/instruments/accord,
		/datum/supply_pack/instruments/hurdygurdy,
		/datum/supply_pack/instruments/viola,
		// Trade goods
		/datum/supply_pack/narcotics/perfume,
		/datum/supply_pack/jewelry/nomag,
		// Seeds
		/datum/supply_pack/seeds/tangerine,
		// Livestock - more valuable
		/datum/supply_pack/livestock/saiga,
		/datum/supply_pack/livestock/cow,
		/datum/supply_pack/livestock/goat,
		/datum/supply_pack/livestock/pig,
		// Medical supplies
		/datum/supply_pack/tools/surgerybag,
		/datum/supply_pack/tools/prarml,
		/datum/supply_pack/tools/prarmr,
		/datum/supply_pack/tools/prlegl,
		/datum/supply_pack/tools/prlegr
	)
	rare_pool = list(
		// Luxury apparel
		/datum/supply_pack/apparel/luxurydyes,
		/datum/supply_pack/apparel/fancyhat,
		/datum/supply_pack/apparel/hennin,
		/datum/supply_pack/apparel/chaperon,
		// Exotic seafood
		/datum/supply_pack/food/clownfish,
		/datum/supply_pack/food/winevalorred,
		/datum/supply_pack/food/winevalorwhite,
		// Weapons - refined coastal arms
		/datum/supply_pack/weapons/bow2,
		/datum/supply_pack/weapons/rbow,
		/datum/supply_pack/weapons/boltquiver,
		/datum/supply_pack/weapons/arrows,
		/datum/supply_pack/weapons/bolts,
		/datum/supply_pack/weapons/bomb,
		/datum/supply_pack/weapons/tossbladeiron,
		// Jewelry
		/datum/supply_pack/jewelry/silverring,
		// Luxury goods
		/datum/supply_pack/luxury/spectacles_golden,
		// Seeds
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
		/datum/supply_pack/narcotics/moondust,
		/datum/supply_pack/weapons/tossbladesteel
	)

/datum/world_faction/coastal_merchants/initialize_faction_stock()
	..()
	// Coastal merchants prefer luxury items and reagents
	hard_value_multipliers[/obj/item/reagent_containers] = 1.2
	hard_value_multipliers[/obj/item/clothing/ring] = 1.3
