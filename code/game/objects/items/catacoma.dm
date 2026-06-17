/obj/item/book/secret/ledger
	name = "catatoma"
	icon_state = "ledger_0"
	base_icon_state = "ledger"
	title = "Catatoma"
	special_book = TRUE
	var/list/cart = list() // Key: pack datum -> Value: Quantity

/obj/item/book/secret/ledger/fence
	name = "Smuggler's Manifest"
	title = " Smuggler's Manifest"

/obj/item/book/secret/ledger/attack_self(mob/user)
	ui_interact(user)

/obj/item/book/secret/ledger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CatatomaLedger", title)
		ui.open()

/obj/item/book/secret/ledger/ui_data(mob/user)
	var/list/data = list()
	var/datum/world_faction/faction = SSmerchant.active_faction

	// Faction Information
	data["faction_name"] = faction ? faction.faction_name : "None"

	data["categories"] = list("All") + SSmerchant.supply_cats

	var/list/all_packs = list()

	// Ensure we have an active faction and the target list exists before iterating
	if(faction && islist(faction.faction_supply_packs))
		for(var/pack_id in faction.faction_supply_packs)
			var/datum/supply_pack/pack = faction.faction_supply_packs[pack_id]
			if(!pack || pack.contraband)
				continue

			// Cleanly track price trends
			var/list/sanitized_history = list()
			if(islist(pack.cost_history) && length(pack.cost_history))
				for(var/price in pack.cost_history)
					if(isnum(price))
						sanitized_history += price

			if(length(sanitized_history) < 2)
				sanitized_history = list(pack.cost, pack.cost)

			all_packs += list(list(
				"name" = pack.name,
				"desc" = pack.desc,
				"group" = pack.group || "Unassigned",
				"id" = "\ref[pack]",
				"cost" = pack.cost,
				"in_stock" = faction.has_supply_pack(pack.type),
				"history" = sanitized_history
			))

	data["supply_packs"] = all_packs

	// Shopping Cart Processing
	var/list/cart_items = list()
	var/total_mammon = 0

	for(var/datum/supply_pack/pack in cart)
		var/quantity = cart[pack]
		var/pack_ref = "\ref[pack]"
		var/item_mammon = pack.cost * quantity

		total_mammon += item_mammon

		cart_items += list(list(
			"name" = pack.name,
			"id" = pack_ref,
			"quantity" = quantity,
			"mammon_cost" = item_mammon
		))

	data["cart"] = cart_items
	data["total_mammon_cost"] = total_mammon

	return data

/obj/item/book/secret/ledger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	switch(action)
		if("add_to_cart")
			var/datum/supply_pack/pack = locate(params["id"])
			if(!pack)
				return TRUE

			cart[pack]++
			return TRUE

		if("remove_from_cart")
			var/datum/supply_pack/pack = locate(params["id"])
			if(!pack)
				return TRUE

			cart[pack]--
			if(cart[pack] <= 0)
				cart -= pack
			return TRUE

		if("clear_cart")
			cart.Cut()
			return TRUE

		if("submit_order")
			create_order_scroll(usr)
			return TRUE

	return FALSE

/obj/item/book/secret/ledger/proc/create_order_scroll(mob/current_reader)
	if(!length(cart))
		to_chat(usr, "<span class='warning'>Your cart is empty!</span>")
		return

	var/datum/world_faction/faction = SSmerchant.active_faction
	if(!faction)
		to_chat(usr, "<span class='warning'>No active faction found!</span>")
		return

	var/obj/item/paper/scroll/cargo/order = new(get_turf(usr))
	order.orders = cart.Copy()

	// Track the active faction on the scroll instance
	order.buying_from = faction
	order.name = "[faction.faction_name] order scroll ([length(cart)] items)"

	// Calculate total costs
	var/total_mammon_cost = 0
	for(var/datum/supply_pack/pack in cart)
		var/quantity = cart[pack]
		total_mammon_cost += pack.cost * quantity

	to_chat(usr, "<span class='notice'>Order scroll created! Cost: [total_mammon_cost] mammons from [faction.faction_name]</span>")
	order.rebuild_info()

	// Clear the cart
	cart.Cut()
	current_reader.put_in_hands(order)
	to_chat(current_reader, "<span class='notice'>Your order has been written on a scroll.</span>")
