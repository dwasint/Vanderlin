/datum/unit_test/merchant_infinite_money_exploit_check

/datum/unit_test/merchant_infinite_money_exploit_check/Run()
	if(!SSmerchant)
		TEST_FAIL("SSmerchant is uninitialized.")
		return

	if(!length(SSmerchant.world_factions))
		TEST_FAIL("No world_factions found in SSmerchant. Market baseline profiles cannot be checked.")
		return

	for(var/datum/world_faction/faction in SSmerchant.world_factions)

		// Temporarily force max reputation to discover the absolute lowest floor
		// the buyer bias can force supply crate prices down to.
		var/saved_rep = faction.faction_reputation
		faction.faction_reputation = 1000 // Forces Tier 6 (Max Tier)
		var/max_tier = faction.get_reputation_tier()

		var/list/faction_catalog = faction.get_available_supply_packs()
		for(var/pack_id in faction_catalog)
			var/datum/supply_pack/pack = faction_catalog[pack_id]
			if(!pack || pack.static_cost || !pack.baseline_price || !pack.contains)
				continue

			var/floor_cost = pack.baseline_price

			var/total_sell_value = 0

			// Handle packed lists vs single item definitions safely
			var/list/items_to_check = islist(pack.contains) ? pack.contains : list(pack.contains)
			for(var/atom/item_type in items_to_check)
				if(!ispath(item_type))
					continue

				// Emulate get_actual_sell_price() logic at absolute peak baseline market pricing
				var/base_price = SSmerchant.get_item_base_value(item_type)
				if(!base_price || base_price <= 0)
					continue

				// Check modifiers
				var/static_modifier = (item_type in faction.hard_value_multipliers) ? faction.hard_value_multipliers[item_type] : 1
				var/dynamic_modifier = (item_type in faction.sell_value_modifiers) ? faction.sell_value_modifiers[item_type] : 1

				if(dynamic_modifier < 1)
					dynamic_modifier = 1
				total_sell_value += FLOOR(base_price * static_modifier * dynamic_modifier, 1)

			if(total_sell_value >= floor_cost)
				TEST_FAIL("Infinite Money Loop Identified! Faction: [faction.name] | Pack: [pack.name] ([pack.type]). At maximum reputation, this supply pack can bottom out to a floor price of [floor_cost] credits. However, cracking it open and instantly dumping its contents back into the tram yields [total_sell_value] credits at base value, creating a passive infinite money generator.")

		faction.faction_reputation = saved_rep
