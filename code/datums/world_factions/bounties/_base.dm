/datum/bounty
	abstract_type = /datum/bounty
	var/name = "Generic Bounty"
	var/desc = "A request for specific goods or assets."

	// The type of item or path needed to fulfill thebounty
	var/required_path
	var/required_count = 1
	var/current_count = 0

	/// If set, this bounty wants a REAGENT, not a discrete item count.
	/// required_path can still be set alongside this to restrict to a specific container (e.g. only bottles)
	var/required_reagent_type
	var/required_reagent_amount = 0
	var/current_reagent_amount = 0

	// Rewards
	var/reward_reputation = 10
	var/reward_currency = 20

	// A list of items to spawn and ship back with the boat upon completion
	var/list/reward_item_paths = list()

	// Bitmask of target sub-factions/classes demanding thisbounty
	var/demanded_by = PEASANTS

	// Department configuration: list("Tag" = tax_percentage_decimal)
	// Example: list("Tax Enforcement" = 0.10) means a 10% deduction
	var/list/department_cuts = list()

	// Supply pack cost modifiers applied to the faction upon completion
	// Example: list(/datum/supply_pack/food_crate = 0.95) for a 5% discount
	var/list/supply_pack_modifiers = list()

	/// Minimum reputation tier required for this bounty to appear
	var/required_reputation_tier = 0

	/// Maps faction type paths directly to relative weights
	/// Format: list(/datum/world_faction/type = weight)
	var/list/faction_generation_weights = list()

	/// Fallback weight applied if a faction isn't explicitly listed in the weights map above
	var/fallback_weight = 10


/datum/bounty/proc/check_completion(obj/item/delivered_item)
	if(required_reagent_type)
		return check_reagent_completion(delivered_item)

	if(!istype(delivered_item, required_path))
		return FALSE
	current_count++
	if(current_count >= required_count)
		return TRUE
	return FALSE

/datum/bounty/proc/check_reagent_completion(obj/item/delivered_item)
	var/obj/item/reagent_containers/glass/container = delivered_item
	if(!istype(container) || !container.reagents)
		return FALSE

	var/found_amount = container.reagents.get_reagent_amount(required_reagent_type)
	if(found_amount <= 0)
		return FALSE

	current_reagent_amount += found_amount
	current_count = min(current_reagent_amount, required_reagent_amount) // keep handle_selling's current_count >= required_count check valid

	if(current_reagent_amount >= required_reagent_amount)
		return TRUE
	return FALSE

/datum/bounty/proc/fulfill_bounty(datum/world_faction/faction)
	// 1. Process administrative/department deductions
	var/total_cut_percentage = 0
	for(var/dept_tag in department_cuts)
		var/cut = department_cuts[dept_tag]
		process_department_cut(dept_tag, cut)
		total_cut_percentage += cut

	// Apply the remaining currency and full reputation rewards
	var/final_currency = round(reward_currency * (1.0 - min(1.0, total_cut_percentage)))
	faction.faction_reputation += reward_reputation

	// 2. Spawn item rewards directly into the merchant shipping queue
	for(var/reward_path in reward_item_paths)
		var/obj/item/reward_item = new reward_path(null) // Spawn in nullspace
		SSmerchant.sending_stuff |= reward_item

	// 3. Apply permanent or long-term supply pack discounts to the faction market
	if(length(supply_pack_modifiers))
		apply_market_discounts(faction)

	// Trigger UI notifications or feedback
	to_chat(usr, "<span class='boldnotice'>Bounty Fulfled: [name]! (+[reward_reputation] Rep, +[final_currency] Cr)</span>")

/datum/bounty/proc/process_department_cut(department_tag, cut_percentage)
	// Currently does nothing, since no guilds yet
	return


/datum/bounty/proc/apply_market_discounts(datum/world_faction/faction)
	for(var/pack_type in supply_pack_modifiers)
		var/modifier = supply_pack_modifiers[pack_type]

		// Ensure the pack exists within the faction's active catalog
		if(faction.faction_supply_packs[pack_type])
			var/datum/supply_pack/pack = faction.faction_supply_packs[pack_type]
			pack.cost = max(1, round(pack.cost * modifier))
			// Record the history graph drop
			pack.record_cost_history()
