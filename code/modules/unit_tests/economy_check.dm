/datum/unit_test/economy_check/Run()
	if(!SSmerchant)
		TEST_FAIL("SSmerchant is uninitialized.")
		return

	if(!length(SSmerchant.world_factions))
		TEST_FAIL("No world_factions found in SSmerchant. Market baseline profiles cannot be checked.")
		return

	for(var/datum/world_faction/faction in SSmerchant.world_factions)
		var/saved_rep = faction.faction_reputation
		faction.faction_reputation = 1000 // Forces Tier 6 (Max Tier)

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
				if(!ispath(item_type, /atom/movable))
					continue

				var/atom/movable/spawned_item = new item_type(null)
				if(!spawned_item)
					continue

				if(spawned_item.sellprice || SSmerchant.get_item_base_value(spawned_item))
					total_sell_value += faction.get_actual_sell_price(spawned_item, 1)

				if(istype(spawned_item, /obj/item/reagent_containers/glass) || istype(spawned_item, /obj/structure))
					var/list/reagent_values = faction.get_reagent_sell_values(spawned_item)
					for(var/reagent_name in reagent_values)
						var/list/reagent_data = reagent_values[reagent_name]
						var/reagent_value = round(reagent_data[2] * 1) // 1 = standard sell modifier
						if(reagent_value > 0)
							total_sell_value += reagent_value

				for(var/atom/movable/inside in spawned_item.get_all_contents())
					if(inside == spawned_item)
						continue
					if(istype(inside, /obj/item/paper/scroll) || istype(inside, /obj/item/coin))
						continue
					if(!inside.sellprice && !SSmerchant.get_item_base_value(inside))
						continue

					var/inside_price = faction.get_actual_sell_price(inside, 1)
					if(inside_price > 0)
						total_value += inside_price

					if(istype(inside, /obj/item/reagent_containers/glass) || istype(inside, /obj/structure))
						var/list/inside_reagent_values = faction.get_reagent_sell_values(inside)
						for(var/reagent_name in inside_reagent_values)
							var/list/reagent_data = inside_reagent_values[reagent_name]
							var/reagent_value = round(reagent_data[2] * 1)
							if(reagent_value > 0)
								total_sell_value += reagent_value

				// Garbage collect our mock item to avoid hard leaks during runtime tests
				qdel(spawned_item)

			if(total_sell_value >= floor_cost)
				TEST_FAIL("Infinite Money Loop Identified, Faction: [faction.name] | Pack: [pack.name] ([pack.type]). At maximum reputation, this supply pack can bottom out to a floor price of [floor_cost] credits. However, cracking it open and instantly dumping its contents (including sub-items and liquids) back into the tram yields [total_sell_value] credits at real value, creating a passive infinite money generator.")

		// Restore original faction status
		faction.faction_reputation = saved_rep
