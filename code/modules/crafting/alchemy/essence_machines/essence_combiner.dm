
/obj/machinery/essence/combiner
	name = "essence combiner"
	desc = "Fuses multiple alchemical essences into a unified compound."
	icon = 'icons/roguetown/misc/splitter.dmi'
	icon_state = "splitter"
	network_priority = 4

	/// Separate output storage so combined product doesn't mix with raw input
	var/datum/essence_storage/output_storage
	var/combining = FALSE
	var/max_concurrent_recipes = 3

/obj/machinery/essence/combiner/Initialize()
	. = ..()
	storage.max_total = 500
	storage.max_types = 10
	output_storage = new /datum/essence_storage(src)
	output_storage.max_total = 500
	output_storage.max_types = 10
	START_PROCESSING(SSobj, src)

/obj/machinery/essence/combiner/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(output_storage)
		qdel(output_storage)
	return ..()

/obj/machinery/essence/combiner/push_to_linked(datum/essence_storage/from_storage)
	// Input storage: only push surplus (anything no recipe can use)
	if(from_storage == storage)
		push_surplus_to_linked(from_storage)
		return
	// Output storage: push everything, it's all product meant to leave
	..()

/obj/machinery/essence/combiner/build_allowed_types()
	// Accept any essence type that appears in at least one known recipe,
	// up to available input space
	var/list/result = list()
	var/room = storage.space()
	if(room <= 0)
		return result
	for(var/rpath in subtypesof(/datum/essence_combination))
		var/datum/essence_combination/recipe = new rpath
		for(var/etype in recipe.inputs)
			if(!(etype in result))
				result[etype] = room
		qdel(recipe)
	return result

/obj/machinery/essence/combiner/process()
	// Pull raw essences from inbound links into input storage
	pull_from_linked(storage)
	// Push combined output through outbound links
	push_to_linked(output_storage)

/obj/machinery/essence/combiner/attack_hand(mob/living/user)
	if(combining)
		to_chat(user, span_warning("A combination is already in progress."))
		return
	attempt_combination(user)

/obj/machinery/essence/combiner/proc/attempt_combination(mob/living/user)
	if(!storage.contents.len)
		to_chat(user, span_warning("No essences loaded."))
		return

	var/list/queued = list()
	var/list/available = storage.snapshot()
	var/efficiency = GLOB.thaumic_research.get_research_bonus(/datum/thaumic_research_node/combiner_output)

	while(queued.len < max_concurrent_recipes)
		var/datum/essence_combination/recipe = find_matching_combination(available)
		if(!recipe)
			break
		if(GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/alchemy) < recipe.skill_required)
			qdel(recipe)
			break
		for(var/etype in recipe.inputs)
			available[etype] -= recipe.inputs[etype]
			if(available[etype] <= 0)
				available -= etype
		queued += recipe

	if(!queued.len)
		to_chat(user, span_warning("No valid combinations can be made with current essences."))
		return

	var/total_out = 0
	for(var/datum/essence_combination/r in queued)
		total_out += round(r.output_amount * efficiency, 1)

	if(output_storage.space() < total_out)
		to_chat(user, span_warning("Not enough output space for [queued.len] recipe(s)."))
		for(var/datum/essence_combination/r in queued)
			qdel(r)
		return

	begin_bulk_combination(user, queued)

/obj/machinery/essence/combiner/proc/begin_bulk_combination(mob/living/user, list/recipes)
	combining = TRUE
	user.visible_message(span_info("[user] activates [src] for bulk processing ([recipes.len] recipe(s))."))
	update_appearance(UPDATE_OVERLAYS)
	var/speed = GLOB.thaumic_research.get_research_bonus(/datum/thaumic_research_node/combiner_speed)
	var/time = (5 SECONDS + (recipes.len * 2 SECONDS)) / speed
	addtimer(CALLBACK(src, PROC_REF(finish_bulk_combination), user, recipes), time)

/obj/machinery/essence/combiner/proc/finish_bulk_combination(mob/living/user, list/recipes)
	var/list/report = list()
	var/efficiency = GLOB.thaumic_research.get_research_bonus(/datum/thaumic_research_node/combiner_output)
	for(var/datum/essence_combination/recipe in recipes)
		for(var/etype in recipe.inputs)
			storage.remove(etype, recipe.inputs[etype])
		var/out_amount = round(recipe.output_amount * efficiency, 1)
		output_storage.add(recipe.output_type, out_amount)
		var/datum/thaumaturgical_essence/e = new recipe.output_type
		report["[e.name]"] = (report["[e.name]"] || 0) + out_amount
		qdel(e)
		qdel(recipe)
	combining = FALSE
	update_appearance(UPDATE_OVERLAYS)
	var/list/parts = list()
	for(var/label in report)
		parts += "[label] ([report[label]] units)"
	visible_message(span_info("[src] finishes: [jointext(parts, ", ")]."))
	var/boon = user.get_learning_boon(/datum/attribute/skill/craft/alchemy)
	var/xp = GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) * recipes.len
	user.adjust_experience(/datum/attribute/skill/craft/alchemy, xp * boon, FALSE)

/obj/machinery/essence/combiner/proc/find_matching_combination(list/available)
	for(var/rpath in subtypesof(/datum/essence_combination))
		var/datum/essence_combination/recipe = new rpath
		var/ok = TRUE
		for(var/etype in recipe.inputs)
			if((available[etype] || 0) < recipe.inputs[etype])
				ok = FALSE
				break
		if(ok)
			return recipe
		qdel(recipe)
	return null

/obj/machinery/essence/combiner/get_mechanics_examine(mob/user)
	. = ..()
	. += span_notice("=== Output ===")
	if(output_storage.contents.len)
		for(var/etype in output_storage.contents)
			var/datum/thaumaturgical_essence/e = new etype
			var/label = HAS_TRAIT(user, TRAIT_LEGENDARY_ALCHEMIST) \
				? e.name : "essence smelling of [e.smells_like]"
			. += span_notice("  — [label]: [output_storage.contents[etype]] units")
			qdel(e)
	else
		. += span_notice("  (empty)")
	if(combining)
		. += span_warning("Combination in progress…")
