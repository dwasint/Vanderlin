#define PLEDGE_BLANK "blank"
#define PLEDGE_FILLED "filled"
#define PLEDGE_SEALED "sealed"
#define PLEDGE_POSTED "posted"

/obj/item/paper/scroll/quest/pledge
	name = "blank quest pledge"
	desc = "A heavy parchment with an ornate guild seal at the top. Fill it out to commission a quest."
	icon_state = "scroll_blank"

	var/pledge_state = PLEDGE_BLANK

	var/pledge_title = ""
	var/pledge_objective = ""
	var/pledge_mode = "" // "item" or "freeform"
	var/pledge_item_type = null // /obj/item subtype, item mode only
	var/pledge_item_name = ""
	var/pledge_item_count = 1
	var/pledge_difficulty = QUEST_DIFFICULTY_EASY
	var/pledge_reward = 0 // mammons promised

	var/pledge_assassin_target = ""
	var/pledge_delivery_target = ""
	var/list/obj/item/packed_delivery_items = list()

	/// Mammons actually held inside the scroll after sealing.
	var/escrowed_mammons = 0

	/// Weakref to the live /datum/quest/custom once posted.
	var/datum/weakref/posted_quest_ref

/obj/item/paper/scroll/quest/pledge/examine(mob/user)
	. = ..()
	if(pledge_mode == "assassinate" && pledge_assassin_target)
		. += span_notice("Target: <b>[pledge_assassin_target]</b>")
	if(pledge_mode == "delivery" && pledge_delivery_target)
		. += span_notice("Recipient: <b>[pledge_delivery_target]</b>")
	if(pledge_mode == "delivery" && length(packed_delivery_items))
		. += span_notice("Packed items:")
		for(var/obj/item/I in packed_delivery_items)
			. += span_notice(" -- [I.name]")
	switch(pledge_state)
		if(PLEDGE_BLANK)
			. += span_notice("The parchment is blank. Use it in-hand to fill out a quest commission.")
		if(PLEDGE_FILLED)
			. += span_notice("Title: <b>[pledge_title]</b>")
			. += span_notice("Difficulty: [pledge_difficulty] | Reward offered: [pledge_reward] mammons")
			if(pledge_mode == "item")
				. += span_notice("Objective: Bring [pledge_item_count]x [pledge_item_name].")
			else
				. += span_notice("Objective: [pledge_objective]")
			. += span_warning("Not yet sealed. Coins have not been committed.")
		if(PLEDGE_SEALED)
			. += span_notice("Title: <b>[pledge_title]</b>")
			. += span_notice("Difficulty: [pledge_difficulty] | Reward escrowed: [escrowed_mammons] mammons")
			. += span_warning("SEALED. Hand to a steward to post, or activate to unseal and reclaim coins.")
		if(PLEDGE_POSTED)
			. += span_notice("This pledge has been posted to the guild board. The quest is now live.")

/obj/item/paper/scroll/quest/pledge/attack_self(mob/living/carbon/human/user)
	switch(pledge_state)
		if(PLEDGE_BLANK)
			do_fill_out(user)
		if(PLEDGE_FILLED)
			var/choice = tgui_input_list(user, "What would you like to do?", "Quest Pledge",
				list("Edit / Review", "Seal & Commit Coins", "Discard"))
			switch(choice)
				if("Edit / Review")
					do_fill_out(user)
				if("Seal & Commit Coins")
					do_seal(user)
				if("Discard")
					qdel(src)
		if(PLEDGE_SEALED)
			var/choice = tgui_input_list(user, "This pledge is sealed. Unseal to reclaim your coins?",
				"Quest Pledge", list("Unseal & Refund", "Cancel"))
			if(choice == "Unseal & Refund")
				do_unseal(user)
		if(PLEDGE_POSTED)
			to_chat(user, span_warning("This pledge has already been posted. It cannot be altered."))

/obj/item/paper/scroll/quest/pledge/proc/do_fill_out(mob/user)
	var/list/mode_choices = list(
		"Item Collection",
		"Freeform (Manually Verified)",
		"Player Assassination",
		"Item Delivery",
	)
	var/mode_choice = tgui_input_list(user, "What kind of quest are you commissioning?", "Quest Pledge", mode_choices)
	if(!mode_choice)
		return

	var/list/diff_choices = list(QUEST_DIFFICULTY_EASY, QUEST_DIFFICULTY_MEDIUM, QUEST_DIFFICULTY_HARD)
	var/diff = tgui_input_list(user, "Difficulty level?", "Quest Pledge Difficulty", diff_choices)
	if(!diff)
		return

	var/min_reward = get_min_reward(diff)
	var/offered = tgui_input_number(user,
		"How many mammons will you offer? (Minimum for [diff]: [min_reward])",
		"Quest Reward", max(pledge_reward, min_reward), 9999, min_reward)
	if(!offered || offered < min_reward)
		to_chat(user, span_warning("Reward must be at least [min_reward] mammons for a [diff] quest."))
		return

	switch(mode_choice)
		if("Item Collection")
			var/search_query = tgui_input_text(user, "Search for the item adventurers must bring:", "Item Search", pledge_item_name, 60)
			if(!search_query)
				return
			var/list/results = search_item_types_global(search_query)
			if(!length(results))
				to_chat(user, span_warning("No items found matching '[search_query]'."))
				return
			var/chosen_name = tgui_input_list(user, "Select the item:", "Item Search Results", results)
			if(!chosen_name)
				return
			var/count = tgui_input_number(user, "How many [chosen_name] are needed?", "Item Count", max(pledge_item_count, 1), 10, 1)
			if(!count || count < 1)
				return
			pledge_mode = "item"
			pledge_item_type = results[chosen_name]
			pledge_item_name = chosen_name
			pledge_item_count = count

		if("Freeform (Manually Verified)")
			var/obj_text = tgui_input_text(user, "Describe what the adventurer must do:", "Quest Objective", pledge_objective, 200)
			if(!obj_text)
				return
			pledge_mode = "freeform"
			pledge_objective = obj_text

		if("Player Assassination")
			var/list/player_names = list()
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.real_name)
					player_names += H.real_name
			player_names = sortList(player_names)
			if(!length(player_names))
				to_chat(user, span_warning("No valid targets are currently online."))
				return
			var/chosen = tgui_input_list(user, "Select the target:", "Assassination Target", player_names)
			if(!chosen)
				return
			pledge_mode = "assassinate"
			pledge_assassin_target = chosen

		if("Item Delivery")
			var/list/player_names = list()
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.real_name)
					player_names += H.real_name
			player_names = sortList(player_names)
			if(!length(player_names))
				to_chat(user, span_warning("No valid recipients are currently online."))
				return
			var/chosen = tgui_input_list(user, "Who should receive the parcel?", "Delivery Recipient", player_names)
			if(!chosen)
				return
			pledge_mode = "delivery"
			pledge_delivery_target = chosen
			to_chat(user, span_notice("Recipient set to [chosen]. Attack this pledge with up to 5 items to pack them, then seal it."))

	var/auto_title = generate_pledge_title()
	var/custom_title = tgui_input_text(user, "Give this quest a title (blank = auto):", "Quest Title", pledge_title, 80)
	pledge_title = custom_title ? custom_title : auto_title
	pledge_difficulty = diff
	pledge_reward = offered
	pledge_state = PLEDGE_FILLED
	name = "quest pledge: [pledge_title]"
	desc = "A filled quest pledge offering [pledge_reward] mammons. Seal it to commit the coins."
	to_chat(user, span_notice("Pledge filled out. Activate in hand again to seal and commit your coins."))

/obj/item/paper/scroll/quest/pledge/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(pledge_mode == "delivery" && pledge_state == PLEDGE_FILLED)
		if(!(I in user))
			return ..()
		if(length(packed_delivery_items) >= 5)
			to_chat(user, span_warning("The pledge can hold at most 5 items."))
			return
		I.forceMove(src)
		packed_delivery_items += I
		to_chat(user, span_notice("You tuck [I.name] into the pledge. ([length(packed_delivery_items)]/5)"))
		return
	return ..()

/obj/item/paper/scroll/quest/pledge/proc/do_seal(mob/user)
	if(pledge_state != PLEDGE_FILLED)
		return

	if(!pledge_title || !pledge_mode || pledge_reward < 1)
		to_chat(user, span_warning("The pledge isn't fully filled out."))
		return

	var/balance = get_mammons_in_atom(user)
	if(balance < pledge_reward)
		to_chat(user, span_warning("You don't have enough mammons. You need [pledge_reward] but only have [balance]."))
		return

	if(!tgui_alert(user,
		"Sealing will take [pledge_reward] mammons from you and hold them in this scroll.\nYou can unseal it later to reclaim the coins if the quest hasn't been posted yet.",
		"Confirm Seal", list("Seal It", "Cancel")) == "Seal It")
		return

	if(!remove_mammons_from_atom(user, pledge_reward))
		to_chat(user, span_warning("Failed to deduct mammons. Make sure you have enough in your coin purse."))
		return

	escrowed_mammons = pledge_reward
	pledge_state = PLEDGE_SEALED
	name = "SEALED quest pledge: [pledge_title]"
	desc = "A sealed quest pledge. The [escrowed_mammons] mammon reward is held inside. Hand to a steward to post."
	to_chat(user, span_notice("Sealed! The scroll now holds [escrowed_mammons] mammons in escrow. Take it to a guild steward to have it posted."))

/obj/item/paper/scroll/quest/pledge/proc/do_unseal(mob/user)
	if(pledge_state != PLEDGE_SEALED)
		return

	var/refund = escrowed_mammons
	escrowed_mammons = 0
	add_mammons_to_atom(user, refund)

	pledge_state = PLEDGE_FILLED
	name = "quest pledge: [pledge_title]"
	desc = "A filled quest pledge offering [pledge_reward] mammons. Seal it to commit the coins."
	to_chat(user, span_notice("Unsealed. [refund] mammons returned to you."))

/obj/item/paper/scroll/quest/pledge/proc/post_to_board(mob/steward, obj/structure/notice_board/board)
	if(pledge_state != PLEDGE_SEALED)
		to_chat(steward, span_warning("This pledge isn't sealed yet."))
		return null

	if(!escrowed_mammons || escrowed_mammons < 1)
		to_chat(steward, span_warning("No coins are escrowed in this pledge."))
		return null

	// Build the quest datum
	var/datum/quest/custom/CQ = new()
	CQ.quest_difficulty = pledge_difficulty
	CQ.reward_amount = escrowed_mammons // whatever was locked in
	CQ.custom_mode = pledge_mode
	CQ.title = pledge_title
	CQ.quest_giver_reference = WEAKREF(steward) // steward is responsible for validation
	CQ.quest_giver_name = steward.real_name

	switch(pledge_mode)
		if("assassinate")
			if(!pledge_assassin_target)
				to_chat(steward, span_warning("No assassination target is recorded in this pledge."))
				return null
			if(pledge_state != PLEDGE_SEALED || !escrowed_mammons)
				to_chat(steward, span_warning("This pledge isn't sealed yet."))
				return null
			var/datum/quest/custom/assassinate/AQ = new()
			AQ.quest_difficulty = pledge_difficulty
			AQ.reward_amount = escrowed_mammons
			AQ.title = pledge_title
			AQ.quest_giver_reference = WEAKREF(steward)
			AQ.quest_giver_name = steward.real_name
			AQ.target_player_name = pledge_assassin_target
			AQ.custom_mode = "assassinate"
			if(!SSquestboard.issue_custom_quest_funded(steward, AQ, escrowed_mammons))
				to_chat(steward, span_warning("The board couldn't accept this pledge right now."))
				qdel(AQ)
				return null
			escrowed_mammons = 0
			pledge_state = PLEDGE_POSTED
			posted_quest_ref = WEAKREF(AQ)
			name = "posted quest pledge: [pledge_title]"
			desc = "This pledge has been accepted by the guild. The quest is now live on the board."
			AQ.generate(null)
			AQ.pledge_ref = WEAKREF(src)
			return AQ

		if("delivery")
			if(!pledge_delivery_target)
				to_chat(steward, span_warning("No delivery recipient is recorded in this pledge."))
				return null
			if(pledge_state != PLEDGE_SEALED || !escrowed_mammons)
				to_chat(steward, span_warning("This pledge isn't sealed yet."))
				return null
			var/datum/quest/custom/delivery/DQ = new()
			DQ.quest_difficulty = pledge_difficulty
			DQ.reward_amount = escrowed_mammons
			DQ.title = pledge_title
			DQ.quest_giver_reference = WEAKREF(steward)
			DQ.quest_giver_name = steward.real_name
			DQ.delivery_target_name = pledge_delivery_target
			DQ.custom_mode = "delivery"
			for(var/obj/item/I in packed_delivery_items)
				if(!QDELETED(I))
					DQ.pending_items += I
					I.forceMove(DQ)
			packed_delivery_items.Cut()
			if(!SSquestboard.issue_custom_quest_funded(steward, DQ, escrowed_mammons))
				to_chat(steward, span_warning("The board couldn't accept this pledge right now."))
				for(var/obj/item/I in DQ.pending_items)
					I.forceMove(get_turf(steward))
				qdel(DQ)
				return null
			escrowed_mammons = 0
			pledge_state = PLEDGE_POSTED
			posted_quest_ref = WEAKREF(DQ)
			name = "posted quest pledge: [pledge_title]"
			desc = "This pledge has been accepted by the guild. The quest is now live on the board."
			DQ.generate(null)
			DQ.pledge_ref = WEAKREF(src)
			return DQ
		if("item")
			CQ.custom_item_type = pledge_item_type
			CQ.custom_item_name = pledge_item_name
			CQ.custom_item_count = pledge_item_count
			CQ.progress_required = pledge_item_count
		else
			CQ.custom_objective_text = pledge_objective

	// Fund the quest from escrowed coins (bypass normal treasury check)
	if(!SSquestboard.issue_custom_quest_funded(steward, CQ, escrowed_mammons))
		to_chat(steward, span_warning("The board couldn't accept this pledge right now."))
		qdel(CQ)
		return null

	escrowed_mammons = 0
	pledge_state = PLEDGE_POSTED
	posted_quest_ref = WEAKREF(CQ)
	name = "posted quest pledge: [pledge_title]"
	desc = "This pledge has been accepted by the guild. The quest is now live on the board."

	CQ.generate(null)
	CQ.pledge_ref = WEAKREF(src)
	return CQ

/obj/item/paper/scroll/quest/pledge/proc/generate_pledge_title()
	switch(pledge_mode)
		if("item")
			return "Bring [pledge_item_count]x [pledge_item_name]"
		if("assassinate")
			return "Eliminate [pledge_assassin_target ? pledge_assassin_target : "unknown target"]"
		if("delivery")
			return "Deliver parcel to [pledge_delivery_target ? pledge_delivery_target : "unknown recipient"]"
	return "Commission: [pledge_objective ? copytext(pledge_objective, 1, 40) : "Unknown"]"

/obj/item/paper/scroll/quest/pledge/proc/get_min_reward(diff)
	switch(diff)
		if(QUEST_DIFFICULTY_EASY)
			return 50
		if(QUEST_DIFFICULTY_MEDIUM)
			return 150
		if(QUEST_DIFFICULTY_HARD)
			return 300
	return 50

/// Standalone item search used by pledge (mirrors notice_board's proc).
/proc/search_item_types_global(query) //I coulda sworn we had this type of code before but I couldn't find it
	var/list/results = list()
	query = lowertext(query)
	for(var/obj/item/item_type as anything in subtypesof(/obj/item))
		if(IS_ABSTRACT(item_type))
			continue
		var/iname = lowertext(initial(item_type.name))
		if(findtext(iname, query))
			var/display = "[initial(item_type.name)] ([item_type])"
			results[display] = item_type
			if(length(results) >= 20)
				break
	return results

#undef PLEDGE_BLANK
#undef PLEDGE_FILLED
#undef PLEDGE_SEALED
#undef PLEDGE_POSTED
