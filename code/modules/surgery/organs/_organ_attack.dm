/obj/item/organ/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	return handle_organ_attack(I, user, params)

/obj/item/organ/proc/handle_organ_attack(obj/item/tool, mob/living/user, params)
	if(owner && DOING_INTERACTION_WITH_TARGET(user, owner))
		return TRUE
	else if(DOING_INTERACTION_WITH_TARGET(user, src))
		return TRUE
	if(owner && CHECK_BITFIELD(organ_flags, ORGAN_CUT_AWAY))
		for(var/thing in attaching_items)
			if(istype(tool, thing))
				handle_attaching_item(tool, user, params)
				return TRUE
	for(var/thing in healing_items)
		if(istype(tool, thing))
			handle_healing_item(tool, user, params)
			return TRUE
	for(var/thing in healing_tools)
		if(tool.tool_behaviour == thing)
			handle_healing_item(tool, user, params)
			return TRUE
	if(owner && (tool.sharpness == IS_SHARP || tool.tool_behaviour == TOOL_SCALPEL) && !CHECK_BITFIELD(organ_flags, ORGAN_CUT_AWAY))
		handle_cutting_away(tool, user, params)
		return TRUE
	if(tool_behaviour == TOOL_CAUTERY)
		handle_burning_rot(tool, user, params)
		return TRUE

/obj/item/organ/proc/handle_attaching_item(obj/item/tool, mob/living/user, params)
	var/obj/item/natural/stack = tool
	user.visible_message(span_notice("<b>[user]</b> starts attaching \the [src] on \the <b>[owner]</b>..."), \
					span_notice("I start attaching \the [src] on \the <b>[owner]</b>..."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	//owner.custom_pain("OH GOD! There is something ripping me from inside!", 30, FALSE, owner.get_bodypart(current_zone))
	if(!do_after(user, 3 SECONDS, owner))
		to_chat(user, span_warning("I must stand still!"))
		return
	if(istype(stack) && !stack.use(2))
		to_chat(user, span_warning("I don't have enough to attach \the [src]!"))
		return
	user.visible_message(span_notice("<b>[user]</b> attaches \the [src] safely on \the <b>[owner]</b>."), \
						span_notice("I attach \the [src] safely on \the <b>[owner]</b>."))
	organ_flags &= ~ORGAN_CUT_AWAY

/obj/item/organ/proc/handle_healing_item(obj/item/tool, mob/living/user, params)
	var/obj/item/natural/stack = tool
	/*
	if(organ_flags & (ORGAN_DESTROYED|ORGAN_DEAD))
		to_chat(user, span_warning("\The [src] is damaged beyond the point of no return."))
		return
	*/

	if(!damage && !(organ_flags & ORGAN_DESTROYED))
		to_chat(user, span_notice("\The [src] is in pristine quality already."))
		return
	user.visible_message(span_notice("<b>[user]</b> starts healing \the [src]..."), \
					span_notice("I start healing \the [src]..."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	if(owner)
		//owner.custom_pain("OH GOD! There are needles inside my [src]!", 30, FALSE, owner.get_bodypart(current_zone))
		if(!do_after(user, 5 SECONDS, owner))
			to_chat(user, span_warning("I must stand still!"))
			return
	else
		if(!do_after(user, 5 SECONDS, src))
			to_chat(user, span_warning("I must stand still!"))
			return
	if(istype(stack))
		if(!stack.use(2))
			to_chat(user, span_warning("I don't have enough to heal \the [src]!"))
			return
	user.visible_message(span_notice("<b>[user]</b> healing \the [src]."), \
						span_notice("I heal \the [src]."))
	applyOrganDamage(-min(maxHealth/2, 50))
	if(organ_flags & ORGAN_DESTROYED)
		organ_flags &= ~ORGAN_DESTROYED //I am having pity on people here at this point I won't force you to get new organs unless they fully necrose.
		for(var/slot in organ_efficiency)
			organ_efficiency[slot] = max(60, organ_efficiency[slot] - 10)

/obj/item/organ/proc/handle_cutting_away(obj/item/tool, mob/living/user, params)
	user.visible_message(span_notice("<b>[user]</b> starts severing \the [src] from \the [owner]..."), \
					span_notice("I start severing \the [src] from \the [owner]..."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	//owner.custom_pain("OH GOD! My [src] is being STABBED!", 30, FALSE, owner.get_bodypart(current_zone))
	if(!do_after(user, 6 SECONDS, owner))
		to_chat(user, span_warning("I must stand still!"))
		return TRUE
	user.visible_message(span_notice("<b>[user]</b> severs \the [src] away."), \
					span_notice("I sever \the [src] away."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	organ_flags |= ORGAN_CUT_AWAY
	return TRUE

/obj/item/organ/proc/handle_burning_rot(obj/item/tool, mob/living/user, params)
	user.visible_message(span_notice("<b>[user]</b> starts burning rot from \the [src]..."), \
					span_notice("I start burning rot from \the [src]..."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	if(!germ_level)
		to_chat(user, span_notice("\The [src] is free of miasma."))
		return
	//owner.custom_pain("OH GOD! My [src] is being STABBED!", 30, FALSE, owner.get_bodypart(current_zone))
	if(!do_after(user, 6 SECONDS, owner))
		to_chat(user, span_warning("I must stand still!"))
		return TRUE
	user.visible_message(span_notice("<b>[user]</b> burn the rot away from \the [src]."), \
					span_notice("I burn the rot away from \the [src]."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	set_germ_level(GERM_LEVEL_STERILE)
	return TRUE
