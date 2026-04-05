/datum/attribute_modifier/lobotomy
	id = "Lobotomy"
	attribute_list = list(STAT_INTELLIGENCE = -3)

/datum/attribute_modifier/lobotomite
	id = "Super Lobotomy"
	attribute_list = list(STAT_INTELLIGENCE = -5)

/obj/item/organ/brain
	name = "brain"
	desc = ""
	icon_state = "brain"
	throw_speed = 1
	throw_range = 5
	layer = ABOVE_MOB_LAYER
	zone = BODY_ZONE_PRECISE_SKULL
	slot = ORGAN_SLOT_BRAIN
	organ_efficiency = list(ORGAN_SLOT_BRAIN = 100)
	organ_flags = ORGAN_VITAL
	attack_verb = list("attacked", "slapped", "whacked")

	maxHealth = BRAIN_DAMAGE_DEATH
	healing_factor = BRAIN_DAMAGE_DEATH/200
	low_threshold = BRAIN_DAMAGE_DEATH * 0.25
	high_threshold = BRAIN_DAMAGE_DEATH * 0.75

	// the volume shouldn't worry you, the chest is full of organs - also getting shot in the heart sucks
	organ_volume = 0.5
	max_blood_storage = 100
	current_blood = 100
	blood_req = 10
	oxygen_req = 5
	nutriment_req = 5
	hydration_req = 5

	/// This is stuff
	var/damage_threshold_value = BRAIN_DAMAGE_DEATH/10

	var/suicided = FALSE
	var/mob/living/brain/brainmob = null
	var/brain_death = FALSE //if the brainmob was intentionally killed by attacking the brain after removal, or by severe braindamage
	var/decoy_override = FALSE	//if it's a fake brain with no brainmob assigned. Feedback messages will be faked as if it does have a brainmob. See changelings & dullahans.
	//two variables necessary for calculating whether we get a brain trauma or not
	var/damage_delta = 0

	var/list/datum/brain_trauma/traumas = list()

/obj/item/organ/brain/Insert(mob/living/carbon/C, special = FALSE, drop_if_replaced = FALSE, no_id_transfer = FALSE, new_zone = null)
	. = ..()

	name = "brain"

	if(brainmob)
		if(brainmob.mind)
			brainmob.mind.transfer_to(C)
		else
			C.key = brainmob.key

		QDEL_NULL(brainmob)

	for(var/datum/brain_trauma/BT as anything in traumas)
		BT.owner = owner
		BT.on_gain()

	//Update the body's icon so it doesnt appear debrained anymore
	C.update_body()

/obj/item/organ/brain/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	. = ..()
	for(var/datum/brain_trauma/BT as anything in traumas)
		BT.on_lose(TRUE)
		BT.owner = null

	if((!gc_destroyed || (owner && !owner.gc_destroyed)) && !no_id_transfer)
		transfer_identity(C)
	C.update_body()


/obj/item/organ/brain/handle_organ_attack(obj/item/tool, mob/living/user, params)
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
	// LOBOTOMITE
	if(owner && (tool.tool_behaviour == TOOL_HEMOSTAT))
		handle_lobotomy(tool, user, params)
		return TRUE
	if(owner && (tool.sharpness == IS_SHARP || tool.tool_behaviour == TOOL_SCALPEL) && !CHECK_BITFIELD(organ_flags, ORGAN_CUT_AWAY))
		handle_cutting_away(tool, user, params)
		return TRUE

/obj/item/organ/brain/handle_healing_item(obj/item/tool, mob/living/user, params)
	var/obj/item/natural/stack = tool
	if(organ_flags & (ORGAN_DESTROYED|ORGAN_DEAD))
		to_chat(user, span_warning("\The [src] is damaged beyond the point of no return."))
		return
	if(!damage && !length(traumas))
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
	cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)


/obj/item/organ/brain/proc/handle_lobotomy(obj/item/tool, mob/living/user, params)
	user.visible_message(span_notice("<b>[user]</b> starts lobotomizing \the [src]..."), \
					span_notice("I start lobotomizing \the [src]..."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	//owner.custom_pain("OH GOD! My [src] is being SLASHED IN TWAIN!", 30, FALSE, owner.get_bodypart(current_zone))
	if(!do_after(user, 10 SECONDS, owner))
		to_chat(user, span_warning("I must stand still!"))
		return TRUE
	user.visible_message(span_notice("<b>[user]</b> lobotomizes \the [src]."), \
					span_notice("I lobotomize \the [src]."), \
					vision_distance = COMBAT_MESSAGE_RANGE)
	switch(owner.diceroll(GET_MOB_ATTRIBUTE_VALUE(owner, STAT_ENDURANCE), context = DICE_CONTEXT_MENTAL))
		// Cure all traumas, no penalties
		if(DICE_CRIT_SUCCESS)
			cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
		// Cure all traumas, but gain a mild one
		if(DICE_SUCCESS)
			cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
			gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
		// Cure nothing, lose intelligence, go fuck yourself
		if(DICE_FAILURE)
			owner.attributes.add_attribute_modifier(/datum/attribute_modifier/lobotomy, TRUE)
		// Cure nothing, lose intelligence, gain another brain trauma, go fuck yourself
		if(DICE_CRIT_FAILURE)
			owner.attributes.add_attribute_modifier(/datum/attribute_modifier/lobotomite, TRUE)
			gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	return TRUE

/obj/item/organ/brain/prepare_eat(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_ROTMAN))//braaaaaains... otherwise, too important to eat.
		return ..()
	return FALSE

/obj/item/organ/brain/proc/transfer_identity(mob/living/L)
	if(brainmob || decoy_override)
		return
	if(!L.mind)
		return
	brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	brainmob.timeofhostdeath = L.timeofdeath
	brainmob.suiciding = suicided
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	if(L.mind?.current)
		L.mind.transfer_to(brainmob)

/obj/item/organ/brain/examine(mob/user)
	. = ..()

	if(suicided)
		. += "<span class='info'>It's started turning slightly grey. They must not have been able to handle the stress of it all.</span>"
	else if(brainmob)
		if(brainmob.get_ghost(FALSE, TRUE))
			if(brain_death || brainmob.health <= HEALTH_THRESHOLD_DEAD)
				. += "<span class='info'>It's lifeless and severely damaged.</span>"
			else if(organ_flags & ORGAN_FAILING)
				. += "<span class='info'>It seems to still have a bit of energy within it, but it's rather damaged... You may be able to restore it with some <b>mannitol</b>.</span>"
			else
				. += "<span class='info'>I can feel the small spark of life still left in this one.</span>"
		else if(organ_flags & ORGAN_FAILING)
			. += "<span class='info'>It seems particularly lifeless and is rather damaged... You may be able to restore it with some <b>mannitol</b> incase it becomes functional again later.</span>"
		else
			. += "<span class='info'>This one seems particularly lifeless. Perhaps it will regain some of its luster later.</span>"
	else
		if(decoy_override)
			if(organ_flags & ORGAN_FAILING)
				. += "<span class='info'>It seems particularly lifeless and is rather damaged... You may be able to restore it with some <b>mannitol</b> incase it becomes functional again later.</span>"
			else
				. += "<span class='info'>This one seems particularly lifeless. Perhaps it will regain some of its luster later.</span>"
		else
			. += "<span class='info'>This one is completely devoid of life.</span>"

/obj/item/organ/brain/attack(mob/living/carbon/C, mob/user, list/modifiers)
	if(!istype(C))
		return ..()

	add_fingerprint(user)

	if(user.zone_selected != BODY_ZONE_HEAD)
		return ..()

	var/target_has_brain = C.getorgan(/obj/item/organ/brain)

	if(!target_has_brain && C.is_eyes_covered())
		to_chat(user, "<span class='warning'>You're going to need to remove [C.p_their()] head cover first!</span>")
		return

	if(!target_has_brain)
		if(!C.get_bodypart(BODY_ZONE_HEAD) || !user.temporarilyRemoveItemFromInventory(src))
			return
		var/msg = "[C] has [src] inserted into [C.p_their()] head by [user]."
		if(C == user)
			msg = "[user] inserts [src] into [user.p_their()] head!"

		C.visible_message("<span class='danger'>[msg]</span>",
						"<span class='danger'>[msg]</span>")

		if(C != user)
			to_chat(C, "<span class='notice'>[user] inserts [src] into your head.</span>")
			to_chat(user, "<span class='notice'>I insert [src] into [C]'s head.</span>")
		else
			to_chat(user, "<span class='notice'>I insert [src] into your head.</span>")

		Insert(C)
	else
		..()

/obj/item/organ/brain/Destroy()
	if(brainmob)
		QDEL_NULL(brainmob)
	QDEL_LIST(traumas)
	return ..()

/obj/item/organ/brain/proc/past_damage_threshold(threshold)
	return (get_current_damage_threshold() > threshold)

/obj/item/organ/brain/proc/get_current_damage_threshold()
	return FLOOR(damage / damage_threshold_value, 1)

// on_life() and check_damage_thresholds() are intentionally omitted here.
// All brain processing is handled by /datum/organ_process/brain.

/obj/item/organ/brain/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!owner)
		return
	if(damage >= 60)
		owner.add_stress(/datum/stress_event/brain_damage)
	else
		owner.remove_stress(/datum/stress_event/brain_damage)

/obj/item/organ/brain/before_organ_replacement(obj/item/organ/replacement)
	. = ..()
	var/obj/item/organ/brain/replacement_brain = replacement
	if(!istype(replacement_brain))
		return

	// Transfer over traumas as well
	for(var/datum/brain_trauma/trauma as anything in traumas)
		cure_trauma_type(trauma)
		replacement_brain.gain_trauma_type(trauma)

////////////////////////////////////TRAUMAS////////////////////////////////////////

/obj/item/organ/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	for(var/datum/brain_trauma/BT as anything in traumas)
		if(istype(BT, brain_trauma_type) && (BT.resilience <= resilience))
			return BT

/obj/item/organ/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	. = list()
	for(var/datum/brain_trauma/BT as anything in traumas)
		if(istype(BT, brain_trauma_type) && (BT.resilience <= resilience))
			. += BT

/obj/item/organ/brain/proc/can_gain_trauma(datum/brain_trauma/trauma, resilience)
	if(!ispath(trauma))
		trauma = trauma.type
	if(!initial(trauma.can_gain))
		return FALSE
	if(!resilience)
		resilience = initial(trauma.resilience)

	var/resilience_tier_count = 0
	for(var/X in traumas)
		if(istype(X, trauma))
			return FALSE
		var/datum/brain_trauma/T = X
		if(resilience == T.resilience)
			resilience_tier_count++

	var/max_traumas
	switch(resilience)
		if(TRAUMA_RESILIENCE_BASIC)
			max_traumas = TRAUMA_LIMIT_BASIC
		if(TRAUMA_RESILIENCE_SURGERY)
			max_traumas = TRAUMA_LIMIT_SURGERY
		if(TRAUMA_RESILIENCE_LOBOTOMY)
			max_traumas = TRAUMA_LIMIT_LOBOTOMY
		if(TRAUMA_RESILIENCE_MAGIC)
			max_traumas = TRAUMA_LIMIT_MAGIC
		if(TRAUMA_RESILIENCE_ABSOLUTE)
			max_traumas = TRAUMA_LIMIT_ABSOLUTE

	if(resilience_tier_count >= max_traumas)
		return FALSE
	return TRUE

/obj/item/organ/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain_gain_trauma(trauma, resilience, arguments)

/obj/item/organ/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!LAZYLEN(arguments))
			actual_trauma = new trauma()
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain) //we don't accept used traumas here
		WARNING("gain_trauma was given an already active trauma.")
		return

	traumas += actual_trauma
	actual_trauma.brain = src
	if(owner)
		actual_trauma.owner = owner
		actual_trauma.on_gain()
	if(resilience)
		actual_trauma.resilience = resilience
	. = actual_trauma
	SSblackbox.record_feedback("tally", "traumas", 1, actual_trauma.type)

/obj/item/organ/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/list/datum/brain_trauma/possible_traumas = list()
	for(var/datum/brain_trauma/BT as anything in subtypesof(brain_trauma_type))
		if(can_gain_trauma(BT, resilience) && initial(BT.random_gain))
			possible_traumas += BT

	if(!LAZYLEN(possible_traumas))
		return

	var/trauma_type = pick(possible_traumas)
	gain_trauma(trauma_type, resilience)

/obj/item/organ/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/traumas = get_traumas_type(brain_trauma_type, resilience)
	if(LAZYLEN(traumas))
		qdel(pick(traumas))

/obj/item/organ/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/traumas = get_traumas_type(resilience = resilience)
	for(var/X in traumas)
		qdel(X)

/obj/item/organ/brain/alien
	name = "alien brain"
	desc = ""
	icon_state = "brain-x"

/obj/item/organ/brain/smooth
	icon_state = "brain-smooth"
