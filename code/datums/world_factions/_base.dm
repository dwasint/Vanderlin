/datum/world_faction
	var/name = "World"
	var/desc = "The entirety of the world"
	var/faction_name
	var/list/sell_value_modifiers = list()
	var/list/last_sell_modification = list()
	var/list/sold_count = list()
	var/list/price_change_manifest = list()
	var/list/hard_value_multipliers = list()
	var/faction_reputation = 0

	var/list/faction_supply_packs = list() // This faction's available supply packs
	var/list/bounty_items = list() // Items this faction wants with multipliers
	var/list/bounty_refresh_times = list() // When each bounty expires
	var/next_supply_rotation = 0 // When supply packs refresh
	var/supply_rotation_interval = 30 MINUTES // How often supplies rotate
	var/bounty_rotation_interval = 15 MINUTES // How often bounties rotate
	var/base_max_bounties = 5 // Base maximum number of active bounties
	var/base_max_supply_packs = 15 // Base maximum supply packs available at once
	var/faction_color = "#FFFFFF" // Color for UI theming

	// Reputation thresholds and bonuses
	var/list/reputation_thresholds = list(0, 100, 300, 600, 1000, 1500, 2500) // Rep levels
	var/bounty_rep_reward_base = 10 // Base rep for completing bounties
	var/supply_rep_reward_base = 5 // Base rep for buying supplies

	// Essential items that are always in stock
	var/list/essential_packs = list()

	// Weighted pools for different item categories
	var/list/common_pool = list()      // Weight 50
	var/list/uncommon_pool = list()    // Weight 30
	var/list/rare_pool = list()        // Weight 15
	var/list/exotic_pool = list()      // Weight 5

	// Pool weights (should add up to 100)
	var/common_weight = 50
	var/uncommon_weight = 30
	var/rare_weight = 15
	var/exotic_weight = 5

	// How many items from each pool to select (beyond essentials) - base values
	var/base_common_picks = 8
	var/base_uncommon_picks = 4
	var/base_rare_picks = 2
	var/base_exotic_picks = 1

/datum/world_faction/New()
	..()
	initialize_faction_stock()
	generate_initial_bounties()

// Get current reputation tier (0-6)
/datum/world_faction/proc/get_reputation_tier()
	var/tier = 0
	for(var/threshold in reputation_thresholds)
		if(faction_reputation >= threshold)
			tier++
		else
			break
	return max(0, tier - 1) // Adjust since we increment before breaking

// Get maximum bounties based on reputation
/datum/world_faction/proc/get_max_bounties()
	var/tier = get_reputation_tier()
	return base_max_bounties + tier // Each tier adds 1 more bounty slot

// Get maximum supply packs based on reputation
/datum/world_faction/proc/get_max_supply_packs()
	var/tier = get_reputation_tier()
	return base_max_supply_packs + (tier * 2) // Each tier adds 2 more supply slots

// Get adjusted pool picks based on reputation
/datum/world_faction/proc/get_pool_picks()
	var/tier = get_reputation_tier()
	var/bonus_multiplier = 1 + (tier * 0.15) // 15% more items per tier

	var/list/picks = list()
	picks["common"] = max(base_common_picks, round(base_common_picks * bonus_multiplier))
	picks["uncommon"] = max(base_uncommon_picks, round(base_uncommon_picks * bonus_multiplier))
	picks["rare"] = max(base_rare_picks, round(base_rare_picks * bonus_multiplier))
	picks["exotic"] = max(base_exotic_picks, round(base_exotic_picks * bonus_multiplier))

	return picks

/datum/world_faction/proc/initialize_faction_stock()
	faction_supply_packs.Cut() // Clear existing

	// Always add essential items first
	for(var/pack_type in essential_packs)
		var/datum/supply_pack/pack = new pack_type()
		if(pack.contains)
			faction_supply_packs[pack_type] = pack

	// Add items from weighted pools - use base values for initial setup
	// since reputation might not be initialized yet
	var/tier = get_reputation_tier()
	if(tier == 0 && faction_reputation == 0) // Initial setup
		add_from_pool(common_pool, base_common_picks)
		add_from_pool(uncommon_pool, base_uncommon_picks)
		add_from_pool(rare_pool, base_rare_picks)
		add_from_pool(exotic_pool, base_exotic_picks)
	else // Subsequent setups can use reputation scaling
		var/list/picks = get_pool_picks()
		add_from_pool(common_pool, picks["common"])
		add_from_pool(uncommon_pool, picks["uncommon"])
		add_from_pool(rare_pool, picks["rare"])
		add_from_pool(exotic_pool, picks["exotic"])

	next_supply_rotation = world.time + supply_rotation_interval

// Helper method to add items from a specific pool
/datum/world_faction/proc/add_from_pool(list/pool, picks_count)
	if(!pool || !picks_count)
		return

	var/list/available_pool = pool.Copy()

	for(var/i = 1 to picks_count)
		if(!length(available_pool))
			break

		var/selected_pack = pick(available_pool)
		available_pool -= selected_pack

		// Don't add if already exists (from essentials or another pool)
		if(selected_pack in faction_supply_packs)
			continue

		var/datum/supply_pack/pack = new selected_pack()
		if(pack.contains)
			faction_supply_packs[selected_pack] = pack

/datum/world_faction/proc/generate_initial_bounties()
	// Generate initial bounties from items with sell values
	var/list/potential_bounties = list()
	for(var/obj_type in SSmerchant.staticly_setup_types)
		potential_bounties += obj_type

	var/max_bounties = get_max_bounties()
	for(var/i = 1 to max_bounties)
		if(!length(potential_bounties))
			break
		var/bounty_type = pick(potential_bounties)
		potential_bounties -= bounty_type
		add_bounty(bounty_type)

/datum/world_faction/proc/add_bounty(atom/bounty_type, multiplier)
	if(!multiplier)
		// Generate random multiplier based on faction needs and reputation
		var/tier = get_reputation_tier()
		var/base_min = 12 + (tier * 2) // Higher rep = better base multipliers
		var/base_max = 25 + (tier * 3)
		multiplier = rand(base_min, base_max) / 10

	bounty_items[bounty_type] = multiplier
	bounty_refresh_times[bounty_type] = world.time + bounty_rotation_interval

/datum/world_faction/proc/remove_bounty(atom/bounty_type)
	bounty_items -= bounty_type
	bounty_refresh_times -= bounty_type

/datum/world_faction/proc/rotate_supply_packs()
	if(world.time < next_supply_rotation)
		return

	// Keep essential items, only rotate the pool-based items
	var/list/items_to_remove = list()
	for(var/pack_type in faction_supply_packs)
		if(!(pack_type in essential_packs))
			items_to_remove += pack_type

	// Remove 40% of non-essential items
	var/removal_count = max(1, round(length(items_to_remove) * 0.4))
	for(var/i = 1 to removal_count)
		if(!length(items_to_remove))
			break
		var/removed_pack = pick(items_to_remove)
		items_to_remove -= removed_pack
		faction_supply_packs -= removed_pack

	// Calculate how many new items we need from each pool (reputation-scaled)
	var/current_non_essential = length(faction_supply_packs) - length(essential_packs)
	var/list/picks = get_pool_picks()
	var/target_total = picks["common"] + picks["uncommon"] + picks["rare"] + picks["exotic"]
	var/needed = target_total - current_non_essential

	if(needed > 0)
		// Distribute new picks proportionally
		var/new_common = max(0, round(needed * (common_weight / 100)))
		var/new_uncommon = max(0, round(needed * (uncommon_weight / 100)))
		var/new_rare = max(0, round(needed * (rare_weight / 100)))
		var/new_exotic = max(0, needed - new_common - new_uncommon - new_rare)

		add_from_pool(common_pool, new_common)
		add_from_pool(uncommon_pool, new_uncommon)
		add_from_pool(rare_pool, new_rare)
		add_from_pool(exotic_pool, new_exotic)

	next_supply_rotation = world.time + supply_rotation_interval

/datum/world_faction/proc/rotate_bounties()
	var/list/expired_bounties = list()

	// Check for expired bounties
	for(var/bounty_type in bounty_refresh_times)
		if(world.time >= bounty_refresh_times[bounty_type])
			expired_bounties += bounty_type

	// Remove expired bounties and add new ones
	for(var/expired_bounty in expired_bounties)
		remove_bounty(expired_bounty)

		// Higher reputation = higher chance for replacement bounties
		var/tier = get_reputation_tier()
		var/replacement_chance = 70 + (tier * 5) // 5% more chance per tier

		if(prob(replacement_chance))
			var/list/potential_bounties = list()
			for(var/obj_type in SSmerchant.staticly_setup_types)
				if(!(obj_type in bounty_items))
					potential_bounties += obj_type

			if(length(potential_bounties))
				var/new_bounty = pick(potential_bounties)
				add_bounty(new_bounty)

	// If we have fewer bounties than our max, try to add more
	var/max_bounties = get_max_bounties()
	var/current_bounties = length(bounty_items)

	if(current_bounties < max_bounties)
		var/list/potential_bounties = list()
		for(var/obj_type in SSmerchant.staticly_setup_types)
			if(!(obj_type in bounty_items))
				potential_bounties += obj_type

		var/bounties_to_add = max_bounties - current_bounties
		for(var/i = 1 to bounties_to_add)
			if(!length(potential_bounties))
				break
			var/new_bounty = pick(potential_bounties)
			potential_bounties -= new_bounty
			add_bounty(new_bounty)

// Award reputation for completing bounties
/datum/world_faction/proc/award_bounty_reputation(atom/bounty_type)
	var/base_reward = bounty_rep_reward_base
	var/multiplier = 1

	if(bounty_type in bounty_items)
		multiplier = bounty_items[bounty_type]

	// Higher value bounties give more rep
	var/rep_gain = round(base_reward * multiplier)
	faction_reputation += rep_gain

	// Notify about reputation gain
	to_chat(usr, "<span class='notice'>You gained [rep_gain] reputation with [faction_name]! (Total: [faction_reputation])</span>")

	// Check if they hit a new tier
	var/old_tier = get_reputation_tier()
	if(faction_reputation >= reputation_thresholds[old_tier + 2]) // Check next threshold
		to_chat(usr, "<span class='boldnotice'>You've reached a new reputation tier with [faction_name]! More bounties and supplies are now available.</span>")

// Award reputation for purchasing supplies
/datum/world_faction/proc/award_supply_reputation(datum/supply_pack/pack)
	var/rep_gain = supply_rep_reward_base
	faction_reputation += rep_gain

/datum/world_faction/proc/handle_world_change()
	for(var/obj/atom as anything in last_sell_modification)
		if(last_sell_modification[atom] > world.time - 15 MINUTES)
			continue
		var/current_price = initial(atom.sellprice) * return_sell_modifier(atom)
		sold_count[atom]--
		adjust_sell_multiplier(atom, rand(0.05, 0.15), 1)
		if(return_sell_modifier(atom) == 1)
			last_sell_modification -= atom
		var/new_price = initial(atom.sellprice) * return_sell_modifier(atom)
		if(new_price != current_price)
			changed_sell_prices(atom, current_price, new_price)

	rotate_supply_packs()
	rotate_bounties()

/datum/world_faction/proc/return_sell_modifier(atom/sell_type)
	var/static_modifer = 1
	if(sell_type in hard_value_multipliers)
		static_modifer = hard_value_multipliers[sell_type]

	// Check if this item has a bounty
	var/bounty_modifier = 1
	if(sell_type in bounty_items)
		bounty_modifier = bounty_items[sell_type]

	var/base_modifier = 1
	if(sell_type in sell_value_modifiers)
		base_modifier = sell_value_modifiers[sell_type]

	return base_modifier * static_modifer * bounty_modifier

/datum/world_faction/proc/get_available_supply_packs()
	return faction_supply_packs

/datum/world_faction/proc/has_supply_pack(datum/supply_pack/pack_type)
	return (pack_type in faction_supply_packs)

/datum/world_faction/proc/handle_selling(obj/selling_type)
	sold_count |= selling_type
	sold_count[selling_type]++

	if(selling_type in bounty_items)
		award_bounty_reputation(selling_type) // Award reputation for completing bounty
		remove_bounty(selling_type)

		// Higher reputation = better chance for new bounties
		var/tier = get_reputation_tier()
		var/new_bounty_chance = 60 + (tier * 5)

		if(prob(new_bounty_chance))
			var/list/potential_bounties = list()
			for(var/obj_type in SSmerchant.staticly_setup_types)
				if(!(obj_type in bounty_items))
					potential_bounties += obj_type

			if(length(potential_bounties))
				var/new_bounty = pick(potential_bounties)
				add_bounty(new_bounty)

	if(!prob(sold_count[selling_type] * 10))
		return
	adjust_sell_multiplier(selling_type, -rand(0.01, 0.1))

/datum/world_faction/proc/handle_supply_purchase(datum/supply_pack/pack)
	award_supply_reputation(pack)

/datum/world_faction/proc/adjust_sell_multiplier(obj/change_type, change = 0, maximum)
	if(!change || !change_type)
		return
	sell_value_modifiers[change_type] += change
	if(sell_value_modifiers[change_type] < 0.1)
		sell_value_modifiers[change_type] = 0.1

	if(maximum)
		if(sell_value_modifiers[change_type] > maximum)
			sell_value_modifiers[change_type] = maximum

	last_sell_modification |= change_type
	last_sell_modification[change_type] = world.time

/datum/world_faction/proc/changed_sell_prices(atom/atom_type, old_price, new_price)
	price_change_manifest |= atom_type
	price_change_manifest[atom_type] = list("[old_price]", "[new_price]")

/datum/world_faction/proc/draw_selling_changes()
	var/index_num = 0
	var/list/sell_data = list()
	for(var/atom/list_type as anything in price_change_manifest)
		if(index_num >= 4)
			SSmerchant.sending_stuff |= new /obj/item/paper/scroll/sell_price_changes(null, sell_data, faction_name)
			index_num = 0
			sell_data = list()
			continue
		sell_data |= list_type
		var/list/prices = price_change_manifest[list_type]
		sell_data[list_type] = prices.Copy()

	if(length(sell_data))
		SSmerchant.sending_stuff |= new /obj/item/paper/scroll/sell_price_changes(null, sell_data, faction_name)

/datum/world_faction/proc/setup_sell_data(atom/sell_type)
	sell_value_modifiers |= sell_type
	sell_value_modifiers[sell_type] = 1

/datum/world_faction/proc/get_reputation_status()
	var/tier = get_reputation_tier()
	var/list/tier_names = list("Neutral", "Friendly", "Trusted", "Honored", "Revered", "Exalted", "Legendary")
	var/tier_name = tier_names[min(tier + 1, length(tier_names))]

	var/next_threshold = "MAX"
	if(tier + 1 < length(reputation_thresholds))
		next_threshold = reputation_thresholds[tier + 2]

	return "[tier_name] ([faction_reputation]/[next_threshold])"
