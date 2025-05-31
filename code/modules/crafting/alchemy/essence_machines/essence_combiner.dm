
/obj/machinery/essence/combiner
	name = "essence combiner"
	desc = "An intricate alchemical apparatus used to merge basic essences into more complex compounds. Can handle multiple combination recipes simultaneously."
	icon = 'icons/roguetown/misc/splitter.dmi'
	icon_state = "combiner"
	density = TRUE
	anchored = TRUE
	processing_priority = 3

	var/max_concurrent_recipes = 3


/obj/machinery/essence/combiner/Initialize()
	. = ..()
	input_storage = new /datum/essence_storage(src)
	input_storage.max_total_capacity = 150
	input_storage.max_essence_types = 8

	output_storage = new /datum/essence_storage(src)
	output_storage.max_total_capacity = 100
	output_storage.max_essence_types = 6

/obj/machinery/essence/combiner/process()
	if(!connection_processing)
		return
	var/list/prioritized_connections = sort_connections_by_priority(output_connections)
	for(var/datum/essence_connection/connection in prioritized_connections)
		if(!connection.active || !connection.target)
			continue
		var/datum/essence_storage/target_storage = get_target_storage(connection.target)
		if(!target_storage)
			continue
		for(var/essence_type in output_storage.stored_essences)
			var/available = output_storage.get_essence_amount(essence_type)
			if(available > 0)
				if(!can_target_accept_essence(connection.target, essence_type))
					continue

				var/to_transfer = min(available, connection.transfer_rate)
				var/transferred = output_storage.transfer_to(target_storage, essence_type, to_transfer)
				if(transferred > 0)
					create_essence_transfer_effect(connection.target, essence_type, transferred)
					break

/obj/machinery/essence/combiner/update_overlays()
	. = ..()
	if(length(overlays))
		cut_overlays()

	var/essence_percent = (output_storage.get_total_stored() + input_storage.get_total_stored()) / (input_storage.max_total_capacity + output_storage.max_total_capacity)
	var/level = clamp(CEILING(essence_percent * 7, 1), 1, 7)

	var/mutable_appearance/MA = mutable_appearance(icon, "liquid_[level]")
	MA.color = calculate_mixture_color()
	overlays += MA

	var/mutable_appearance/emissive = mutable_appearance(icon, "liquid_[level]")
	emissive.plane = EMISSIVE_PLANE
	overlays += emissive

	if(processing)
		overlays += mutable_appearance(icon, "combining", ABOVE_MOB_LAYER)

/obj/machinery/essence/combiner/examine(mob/user)
	. = ..()
	. += span_notice("Input Storage: [input_storage.get_total_stored()]/[input_storage.max_total_capacity] units")
	. += span_notice("Output Storage: [output_storage.get_total_stored()]/[output_storage.max_total_capacity] units")

	if(input_storage.stored_essences.len > 0)
		. += span_notice("Ready to combine:")
		for(var/essence_type in input_storage.stored_essences)
			var/datum/thaumaturgical_essence/essence = new essence_type
			. += span_notice("- [essence.name]: [input_storage.stored_essences[essence_type]] units")
			qdel(essence)

/obj/machinery/essence/combiner/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/essence_vial))
		var/obj/item/essence_vial/vial = I
		if(!vial.contained_essence || vial.essence_amount <= 0)
			if(!length(output_storage.stored_essences))
				to_chat(user, span_warning("No essences available for extraction."))
				return
			var/list/available_essences = list()
			for(var/essence_type in output_storage.stored_essences)
				var/datum/thaumaturgical_essence/essence = new essence_type
				available_essences["[essence.name] ([output_storage.stored_essences[essence_type]] units)"] = essence_type
				qdel(essence)

			var/choice = input(user, "Which essence would you like to extract?", "Extract Essence") in available_essences
			if(!choice)
				return

			var/essence_type = available_essences[choice]
			var/max_extract = min(output_storage.get_essence_amount(essence_type), vial.max_essence)
			var/amount_to_extract = input(user, "How much would you like to extract? (Max: [max_extract])", "Extract Amount", max_extract) as num

			if(amount_to_extract <= 0 || amount_to_extract > max_extract)
				return

			var/extracted = output_storage.remove_essence(essence_type, amount_to_extract)
			if(extracted > 0)
				vial.contained_essence = new essence_type
				vial.essence_amount = extracted
				vial.update_icon()
				to_chat(user, span_info("You extract [extracted] units of essence from the output."))
				update_overlays()
			return

		if(processing)
			to_chat(user, span_warning("The combiner is currently processing."))
			return

		var/essence_type = vial.contained_essence.type
		var/amount = vial.essence_amount

		if(!input_storage.add_essence(essence_type, amount))
			to_chat(user, span_warning("The input storage cannot accept this essence (capacity or type limit reached)."))
			return

		to_chat(user, span_info("You pour the [vial.contained_essence.name] into the combiner's input."))
		vial.contained_essence = null
		vial.essence_amount = 0
		vial.update_icon()
		update_overlays()
		return TRUE

	..()

/obj/machinery/essence/combiner/attack_hand(mob/user, params)
	if(processing)
		to_chat(user, span_warning("The combiner is currently processing."))
		return

	var/choice = input(user, "What would you like to do?", "Essence Combiner") in list("Start Combining", "View Storage", "Clear Input", "Cancel")

	switch(choice)
		if("Start Combining")
			attempt_combination(user)
		if("View Storage")
			show_storage_status(user)
		if("Clear Input")
			clear_input_storage(user)

/obj/machinery/essence/combiner/proc/show_storage_status(mob/user)
	var/list/status_text = list()
	status_text += "=== Essence Combiner Status ==="
	status_text += ""
	status_text += "INPUT STORAGE:"
	status_text += "Capacity: [input_storage.get_total_stored()]/[input_storage.max_total_capacity] units"

	if(input_storage.stored_essences.len > 0)
		for(var/essence_type in input_storage.stored_essences)
			var/datum/thaumaturgical_essence/essence = new essence_type
			status_text += "- [essence.name]: [input_storage.stored_essences[essence_type]] units"
			qdel(essence)
	else
		status_text += "- Empty"

	status_text += ""
	status_text += "OUTPUT STORAGE:"
	status_text += "Capacity: [output_storage.get_total_stored()]/[output_storage.max_total_capacity] units"

	if(output_storage.stored_essences.len > 0)
		for(var/essence_type in output_storage.stored_essences)
			var/datum/thaumaturgical_essence/essence = new essence_type
			status_text += "- [essence.name]: [output_storage.stored_essences[essence_type]] units"
			qdel(essence)
	else
		status_text += "- Empty"

	to_chat(user, span_info(jointext(status_text, "\n")))

/obj/machinery/essence/combiner/proc/clear_input_storage(mob/user)
	if(length(input_storage.stored_essences) == 0)
		to_chat(user, span_warning("Input storage is already empty."))
		return
	for(var/essence_type in input_storage.stored_essences)
		var/amount = input_storage.stored_essences[essence_type]
		var/obj/item/essence_vial/new_vial = new(get_turf(src))
		new_vial.contained_essence = new essence_type
		new_vial.essence_amount = amount
		new_vial.update_icon()

	input_storage.stored_essences = list()
	to_chat(user, span_info("You clear the input storage, creating vials for each essence."))

/obj/machinery/essence/combiner/proc/attempt_combination(mob/user)
	if(!length(input_storage.stored_essences))
		to_chat(user, span_warning("No essences loaded for combination."))
		return

	var/list/possible_recipes = list()
	var/list/available_essences = input_storage.stored_essences.Copy()

	while(possible_recipes.len < max_concurrent_recipes)
		var/datum/essence_combination/recipe = find_matching_combination(available_essences)
		if(!recipe)
			break
		if(user.get_skill_level(/datum/skill/craft/alchemy) < recipe.skill_required)
			qdel(recipe)
			break
		var/can_make = TRUE
		for(var/essence_type in recipe.inputs)
			var/required = recipe.inputs[essence_type]
			var/have = available_essences[essence_type] || 0
			if(have < required)
				can_make = FALSE
				break

		if(!can_make)
			qdel(recipe)
			break

		for(var/essence_type in recipe.inputs)
			var/required = recipe.inputs[essence_type]
			available_essences[essence_type] -= required
			if(available_essences[essence_type] <= 0)
				available_essences -= essence_type

		possible_recipes += recipe

	if(!possible_recipes.len)
		to_chat(user, span_warning("No combinations can be performed with current essences."))
		return

	var/total_output = 0
	for(var/datum/essence_combination/recipe in possible_recipes)
		total_output += recipe.output_amount

	if(output_storage.get_available_space() < total_output)
		to_chat(user, span_warning("Not enough space in output storage for bulk combination."))
		for(var/datum/essence_combination/recipe in possible_recipes)
			qdel(recipe)
		return

	begin_bulk_combination(user, possible_recipes)


/obj/machinery/essence/combiner/proc/begin_bulk_combination(mob/living/user, list/recipes)
	processing = TRUE
	user.visible_message(span_info("[user] activates the essence combiner for bulk processing ([recipes.len] recipes)."))
	update_overlays()

	var/process_time = 5 SECONDS + (recipes.len * 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_bulk_combination), user, recipes), process_time)

/obj/machinery/essence/combiner/proc/finish_bulk_combination(mob/living/user, list/recipes)
	var/list/produced_essences = list()

	for(var/datum/essence_combination/recipe in recipes)
		for(var/essence_type in recipe.inputs)
			var/required_amount = recipe.inputs[essence_type]
			input_storage.remove_essence(essence_type, required_amount)

		output_storage.add_essence(recipe.output_type, recipe.output_amount)

		var/datum/thaumaturgical_essence/output_essence = new recipe.output_type
		if(produced_essences[output_essence.name])
			produced_essences[output_essence.name] += recipe.output_amount
		else
			produced_essences[output_essence.name] = recipe.output_amount
		qdel(output_essence)
		qdel(recipe)

	processing = FALSE
	update_overlays()

	var/list/production_report = list()
	for(var/essence_name in produced_essences)
		production_report += "[essence_name] ([produced_essences[essence_name]] units)"

	user.visible_message(span_info("The essence combiner completes bulk processing, producing: [jointext(production_report, ", ")]"))
	var/boon = user.get_learning_boon(/datum/skill/craft/alchemy)
	var/amt2raise = user.STAINT * recipes.len
	user.adjust_experience(/datum/skill/craft/alchemy, amt2raise * boon, FALSE)


/obj/machinery/essence/combiner/proc/find_matching_combination(list/available_essences)
	for(var/recipe_path in subtypesof(/datum/essence_combination))
		var/datum/essence_combination/recipe = new recipe_path
		var/matches = TRUE
		for(var/essence_type in recipe.inputs)
			var/required_amount = recipe.inputs[essence_type]
			var/available_amount = available_essences[essence_type] || 0
			if(available_amount < required_amount)
				matches = FALSE
				break

		if(matches)
			return recipe
		qdel(recipe)

	return null

/obj/machinery/essence/combiner/proc/calculate_mixture_color()
	var/list/essence_contents = list()

	essence_contents |= input_storage.stored_essences
	essence_contents |= output_storage.stored_essences

	if(!length(essence_contents))
		return "#4A90E2"

	var/total_weight = 0
	var/r = 0, g = 0, b = 0

	for(var/essence_type in essence_contents)
		var/datum/thaumaturgical_essence/essence = new essence_type
		var/amount = essence_contents[essence_type]
		var/weight = amount * (essence.tier + 1) // Higher tier essences have more color influence

		total_weight += weight
		var/color_val = hex2num(copytext(essence.color, 2, 4))
		r += color_val * weight
		color_val = hex2num(copytext(essence.color, 4, 6))
		g += color_val * weight
		color_val = hex2num(copytext(essence.color, 6, 8))
		b += color_val * weight

		qdel(essence)

	if(total_weight == 0)
		return "#4A90E2"

	r = FLOOR(r / total_weight, 1)
	g = FLOOR(g / total_weight, 1)
	b = FLOOR(b / total_weight, 1)

	return rgb(r, g, b)
