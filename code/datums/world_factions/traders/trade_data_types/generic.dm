/datum/trader_data/food_merchant
	name = "Food"
	initial_products = list()
	initial_wanteds = list(
		/obj/item/reagent_containers/glass = list(4, INFINITY, ""),
		/obj/item/storage/bag = list(5, INFINITY, ""),
	)
	say_phrases = list(
		TRADER_LORE_PHRASE = list(
			"Fresh goods from distant lands!",
			"Taste the flavors of the world!",
			"My cargo hold is full of delicacies!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Come try exotic cuisines!",
		),
	)

/datum/trader_data/clothing_merchant
	name = "Clothier"
	initial_products = list()
	initial_wanteds = list(
		/obj/item/natural/cloth = list(3, INFINITY, ""),
		/obj/item/dye_pack/cheap = list(15, INFINITY, ""),
	)
	say_phrases = list(
		TRADER_LORE_PHRASE = list(
			"Finest fabrics from across the seas!",
			"Fashion that would make nobles jealous!",
			"Cloth woven by master artisans!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Clothe yourself in foreign finery!",
		),
	)

/datum/trader_data/luxury_merchant
	name = "Luxury"
	initial_products = list()
	initial_wanteds = list(
		/obj/item/ingot/gold = list(30, INFINITY, ""),
		/obj/item/gem = list(20, INFINITY, ""),
	)
	say_phrases = list(
		TRADER_LORE_PHRASE = list(
			"Treasures fit for royalty!",
			"Luxury beyond your wildest dreams!",
			"Each piece tells a story of distant courts!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Behold, wonders from afar!",
		),
	)

/datum/trader_data/tool_merchant
	name = "Tool"
	initial_products = list()
	initial_wanteds = list(
		/obj/item/ingot/iron = list(5, INFINITY, ""),
		/obj/item/natural/wood = list(8, INFINITY, ""),
	)
	say_phrases = list(
		TRADER_LORE_PHRASE = list(
			"Tools forged by master craftsmen!",
			"Implements to make work easier!",
			"Quality instruments from skilled smiths!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Equip yourself with proper tools!",
		),
	)

/datum/trader_data/alchemist
	name = "Alchemical"
	initial_products = list()
	initial_wanteds = list(
		/obj/item/natural/bundle/fibers = list(6, INFINITY, ""),
		/obj/item/ash = list(10, INFINITY, ""),
	)
	say_phrases = list(
		TRADER_LORE_PHRASE = list(
			"Ancient remedies and exotic compounds!",
			"Elixirs brewed in distant laboratories!",
			"Potions that blur the line between medicine and magic!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Sample my mystical concoctions!",
		),
	)

/datum/trader_data/material_merchant
	name = "Material"
	initial_products = list()
	initial_wanteds = list(
		/obj/item/natural/wood/plank = list(5, INFINITY, ""),
		/obj/item/natural/stone = list(7, INFINITY, ""),
	)
	say_phrases = list(
		TRADER_LORE_PHRASE = list(
			"Raw materials from the far corners of the world!",
			"Building blocks for your grandest projects!",
			"Resources gathered from untamed lands!",
		),
		TRADER_SHOP_OPENING_PHRASE = list(
			"Stock up on quality materials!",
		),
	)
